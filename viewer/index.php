<?php
/**
 * A web-based log viewer for Lumberjack.
 *
 * Copyright (C) 2011 Judd Vinet <judd@betsmartmedia.com>
 */

define('DB_ROOT', '../db'); // path to database directory

if($_SERVER['REQUEST_METHOD'] == 'POST') {
	$dbfn = preg_replace('/[^A-z0-9_-]/', '', $_POST['db']);
	$dbpath = DB_ROOT . '/' . $dbfn . '.sq3';
	if(!file_exists($dbpath)) {
		die(json_encode(array('fail'=>"Invalid DB: $dbfn")));
	}

	try {
		$dbh = new PDO('sqlite:' . DB_ROOT . '/' . $dbfn . '.sq3');
	} catch (Exception $e) {
		die(json_encode(array('fail'=>'Cannot connect to database: ' . $e->getMessage())));
	}
	$sql = "SELECT * FROM log_messages WHERE 1=1";
	$args = array();

	foreach($_POST as $k=>$v) {
		if($k == 'db') continue;

		if(!preg_match('/^[A-z0-9_]+$/', $k)) continue; // no SQL injection, please
		if(empty($v)) continue;
		$sql .= " AND $k LIKE ?";
		$args[] = $v;
	}
	$sql .= " ORDER BY created_on DESC LIMIT 100";
	$stmt = $dbh->prepare($sql);
	foreach($args as $i=>$v) {
		$stmt->bindValue($i+1, '%'.$v.'%');
	}
	$stmt->execute();
	$recs = $stmt->fetchAll(PDO::FETCH_ASSOC);

	die(json_encode(array('ok'=>true, 'results'=>$recs)));
}

// Build list of log/project DBs
$databases = array_map(function($v) {
	return substr(array_pop(explode('/', $v)), 0, -4);
}, glob(DB_ROOT . '/*.sq3'));

?>

<html>
<head>
	<title>Lumberjack</title>
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
	<script type="text/javascript" src="date.format.js"></script>
	<style type="text/css">
		body {
			font-family: Arial, Helvetica, sans-serif;
			font-size: 12px;
			background-color: #000;
			color: #ccc;
		}
		#container {
			width: 900px;
			min-height: 100%;
			margin: 0 auto;
			background-color: #202020;
		}
		h1 {
			color: #289442;
			text-align: center;
		}
		input {
			background-color: #666;
			border: 1px inset #999;
			color: #eee;
		}
		#entries {
			width: 100%;
		}
		#entries thead th {
			padding: 4px 4px 4px 0;
			text-align: left;
		}
		#entries tbody td {
			padding: 4px 4px 4px 0;
			vertical-align: top;
			font-size: 11px;
			font-family: monospace;
			border-bottom: 1px solid #666;
			color: #ccc;
		}
	</style>
</head>

<body>
	<div id="container">
		<div style="float:left">
			<select id="project">
			<?php foreach($databases as $db): ?>
				<option value="<?php echo $db ?>"><?php echo $db ?></option>
			<?php endforeach ?>
			</select>
		</div>
		<div style="float:right">
			<input id="refresh" type="checkbox" /> Auto-refresh
		</div>
		<h1>LumberJack</h1>

		<table id="entries" cellspacing="0">
			<thead>
				<tr>
					<th>Date/Time</th>
					<th>Host</th>
					<th>Facility</th>
					<th>Priority</th>
					<th>Message</th>
				</tr>
				<tr>
					<th><input class="filter" type="text" name="created_on" size="20" /></th>
					<th><input class="filter" type="text" name="host" size="10" /></th>
					<th><input class="filter" type="text" name="facility" size="25" /></th>
					<th><input class="filter" type="text" name="priority" size="10" /></th>
					<th><input class="filter" type="text" name="message" size="50" /></th>
				</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>

	<script type="text/javascript">
		var refresh_timer;
		var project = '<?php echo $databases[0] ?>';

		var fetch = function() {
			var colors = {
				debug:   '#90ee90',
				info:    '#4db6f2',
				warning: '#dede00',
				error:   '#ff3300'
			}

			var params = {db: project};
			$('.filter').each(function(){
				params[$(this).attr('name')] = $(this).val();
			});
			$.post(window.location.href, params, function(d) {
				$tb = $('#entries > tbody');
				$tb.empty();

				if(d.fail)     return alert("Error: " + d.fail);
				if(!d.results) return alert("Error fetching results");

				$.each(d.results.reverse(), function(i,v) {
					var d = new Date();
					d.setTime(v.created_on * 1000);

					var msg = v.message
						.replace(/\n/g, '<br />')
						.replace(/\t/g, '  ')
						.replace(/  /g, ' &nbsp;');

					$row = $('<tr></tr>');
					$row.append('<td>' + d.format('UTC:yyyy-mm-dd HH:MM:ss') + '</td>');
					$row.append('<td>' + v.host + '</td>');
					$row.append('<td>' + v.facility + '</td>');
					$row.append('<td>' + v.priority + '</td>');
					$row.append('<td>' + msg + '</td>');

					if(v.priority in colors) {
						$row.find('td').css('color', colors[v.priority]);
					}

					$row.prependTo($tb);
				});
			}, 'json');
		};

		$(function(){
			$('.filter').change(fetch);

			$('#project').change(function(){
				project = $(this).val();
				fetch();
			});

			$('#refresh').click(function() {
				if($(this).prop('checked')) {
					refresh_timer = setInterval(function(){ fetch() }, 5000);
				} else {
					clearInterval(refresh_timer);
				}
			});

			fetch();
		});
	</script>
</body>
</html>
