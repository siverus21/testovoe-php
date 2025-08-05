const { spawn } = require('child_process');

for (let id = 1; id <= 1000; id++) {
	const child = spawn('D:/OSPanel/modules/php/PHP_8.1/php.exe', ['main.php', id]);

	// логируем ответ
	child.stdout.on('data', (data) => {
		process.stdout.write(`${id} - ${data}`);
	});
	// логируем ошибку
	child.stderr.on('data', (data) => {
		process.stderr.write(`${id} ERROR - ${data}`);
	});
}
