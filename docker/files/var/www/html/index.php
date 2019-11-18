<?php
error_reporting(E_ALL & ~E_WARNING & ~E_NOTICE);

if (isset($_GET['showinfo'])) {
    var_dump($_SERVER);
    phpinfo();
    die;
}

try {
    $pdo = new PDO($_SERVER['PGSQL_DSN'], $_SERVER['PGSQL_USER'], $_SERVER['PGSQL_PASS'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
    die('connection error: ' . $e->getMessage());
}

if (isset($_GET['migration'])) {
    try {
        $pdo->query('drop table if exists public.data;');
        $pdo->query('drop sequence if exists public.data_data_id_seq;');
        $pdo->query('CREATE SEQUENCE IF NOT EXISTS data_data_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;');
        $pdo->query('CREATE TABLE IF NOT EXISTS "data" ("data_id" integer DEFAULT nextval(\'data_data_id_seq\'::regclass) NOT NULL, "data_time" integer NOT NULL, "data_ip" bigint NOT NULL );');
    } catch (PDOException $e) {
        die('prepare error: ' . $e->getMessage());
        exit(1);
    }
    die;
} elseif (isset($_GET['showall'])) {
    var_dump($pdo->query('select * from data')->fetchAll());
    die;
}

$q = 'insert into data (data_time, data_ip) VALUES ('.time().', '.ip2long($_SERVER['HTTP_X_FORWARDED_FOR']).')';
try {
    // $pdo->beginTransaction();
    $pdo->query($q);
    // $stmt = $pdo->prepare("insert into data (data_time, data_ip) VALUES (:data_time, :data_ip)");
    // $stmt->bindValue('data_time', time());
    // $stmt->bindValue('data_ip', ip2long($_SERVER['HTTP_X_FORWARDED_FOR']));
    // $stmt->execute();
    // $pdo->commit();
} catch (Exception $e){
    // $pdo->rollback();
    die('query error: ' . $e->getMessage() . ' - ' . $q);
}

$all = $pdo->query('select count(distinct data_ip) from data')->fetch()[0];
$today = $pdo->query('select count(distinct data_ip) from data where data_time > ' . strtotime('now 00:00:00'))->fetch()[0];
$unique = $pdo->query('select count(distinct data_ip) from data where data_time > ' . strtotime('now 00:00:00'))->fetch()[0];

function addSpace($input) {
    $strlen = 17 - strlen($input);
    $space = "";
	while($strlen) { $space.= " "; $strlen--; }
    return $space . $input;
}

header("Content-type: image/png".chr(10).chr(10));

$image=imagecreatetruecolor(88, 31) or die('error creating image');
imagefill($image, 0, 0, imagecolorallocate($image, 0, 102, 204));
imagestring($image, 1, 2, 1, "All", imagecolorallocate($image, 255, 255, 255));
imagestring($image, 1, 2, 12, "Today", imagecolorallocate($image, 255, 255, 255));
imagestring($image, 1, 2, 22, "Unique", imagecolorallocate($image, 255, 255, 255));
imagestring($image, 1, 2, 1, addSpace($all), imagecolorallocate($image, 255, 255, 255));
imagestring($image, 1, 2, 12, addSpace($today), imagecolorallocate($image, 255, 255, 255));
imagestring($image, 1, 2, 22, addSpace($unique), imagecolorallocate($image, 255, 255, 255));
imagepng($image);
