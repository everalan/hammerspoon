<?php namespace everalan\VPN;

use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;
use Symfony\Component\Process\InputStream;

class VPN
{
    protected $pid = 0;//openconnect进程号
    protected $serv;
    protected $state = 'disconnect';

    function __construct()
    {
        $http = new \Swoole\Http\Server("127.0.0.1", 9501, SWOOLE_PROCESS);

        $http->on('connect', function ($serv, $fd){
            $this->serv = $serv;
        });
        $http->on('request', function ($request, $response) {
            switch(trim($request->server['path_info'], '/'))
            {
                case 'state':
                    $response->end($this->state);
                    break;
                case 'connect':
                    if($this->pid)
                    {
                        $response->end('openconnect is running');
                        return;
                    }
                    $this->serv->task('');
                    $response->end("OK");
                    break;    
                case 'disconnect':
                    if(!$this->pid)
                    {
                        $response->end('openconnect is not running');
                        return;
                    }
                    $this->disconnect();
                    break;    
                
            }
            
        }); 
        $http->on('workerstart', function (\swoole_server $serv, $worker_id) {

        });

        $http->on('task', function (\swoole_server $serv, $task_id, $from_id, $data) {
            $this->serv = $serv;
            $this->connect();
            return "OK";
        });

        $http->on('finish', function(\swoole_server $serv, $from_id, $data) {
            $this->state = 'disconnect';
            $this->pid = 0;
        });

        $http->on('pipemessage', function(\swoole_server $server, $src_worker_id, $message){
            echo json_encode($message) . "\n";
            list($act, $val) = $message;
            switch($act)
            {
                case 'state':
                    $this->state = $val;
                    break;
                case 'pid'://保存进程id
                    $this->pid = $val;
                    break;        
            }
        });
        $http->set([
            'enable_coroutine' => false,
            'worker_num' => 1,
            'task_worker_num' => 1,
        ]);
        $http->start();
    }
    


    public function start()
    {
        $http->start();
    }

    public function disconnect()
    {
        exec("kill $this->pid");
    }
    

    protected function connect()
    {
        $p = new Process(['/usr/local/bin/openconnect', '-v', 'vpn.everalan.com'], null, null, "everalan\nx\n", null);
        $p->start();
        $this->serv->sendMessage(json_encode(['pid', $p->getPid()]), 0);;
        $p->wait(function ($type, $buffer){
            foreach(preg_split('/[\r\n]+/', trim($buffer)) as $line)
            {
                echo $line . "\n";
            
                if(preg_match('/^POST /', $line))
                {
                    $this->serv->sendMessage(['state', 'connecting'], 0); //向主进程发送消息
                }
                if(preg_match('/^Connected as /', $line))
                {
                    $this->serv->sendMessage(['state', 'connected'], 0); //向主进程发送消息
                }
                if(preg_match('/^Failed to reconnect to /', $line))
                {
                    $this->serv->sendMessage(['state', 'reconnecting'], 0); //向主进程发送消息
                }
            }
            
        });
        echo "process finished\n";
    }    
}
