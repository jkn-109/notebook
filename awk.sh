awk(作用过滤数据  统计数据   ！！！逐行处理)

awk [选项] '[条件]{指令}' 文件  [ ]：可选项 可有可无  指令print必须放在{}里面
eg:[root@svr5 ~]# awk '{print $1,$3}' test.txt        //打印文档第1列和第3列
结合管道
[root@svr5 ~]# df -h | awk '{print $4}'        //打印磁盘的剩余空间
-F  可指定分隔符  过滤数据时支持仅打印某一列 (未指定分隔符时，以空格、制表符等作为分隔符的是一列)
[root@svr5 ~]# awk -F: '{print $1,$7}' /etc/passwd   //输出passwd文件中以 : 分隔的第1、7个字段
awk还识别多种单个的字符 ' : '  '/'    [  ]:可以匹配方括号里面的任何一个
[root@svr5 ~]# awk -F [:/] '{print $1,$10}' /etc/passwd    //以“:”或“/”分隔，输出第1、10个字段

awk常用内置变量：
$0      文本当前行的全部内容(全行)
$1	文本的第1列
$2	文件的第2列
$3	文件的第3列
...     依此类推
NR	当前行的行号  $NR  是第一行就是第一列
NF	当前行的列数（有几列）$NF 永远是最后一列
eg:[root@server0 ~]# awk -F[,:/] '{print NR,NF}' 2.sh 
     1 4   //第一行 有4列
     2 5   //第二行  有5列
常量一定要用""引起来                  中间的,表示空格
[root@svr5 ~]# awk -F: '{print $1,"的解释器:",$7}' /etc/passwd

案例：
利用awk提取本机的网络流量、根分区剩余容量、获取远程失败的IP地址
RX为接收的数据量，TX为发送的数据量。
packets以数据包的数量为单位，bytes以字节为单位
[root@svr5 ~]# ifconfig eth0 | awk '/RX p/{print $5}'    //过滤接收数据的流量
  319663094
[root@svr5 ~]# ifconfig eth0 | awk '/TX p/{print $5}'     //过滤发送数据的流量
  40791683
tailf /var/log/secure    //动态看日志文件的后10行

格式化输出/etc/passwd文件
                                             //BEGIN{ } 行前处理，读取文件内容前执行，指令执行1次 可以不需要文件
awk [选项] ' BEGIN{指令} {指令} END{指令}' 文件  //{ }  逐行处理，读取文件过程中执行，指令执行n次
                                             //END{ } 行后处理，读取文件结束后执行，指令执行1次
eg:[root@svr5 ~]# awk 'BEGIN{x=0}/bash$/{x++} END{print x}' /etc/passwd
   //预处理时赋值变量x=0 登录Shell是/bin/bash则x加1  输出x的值

column -t   //自动用tab键对齐

awk处理条件
1）正则
^匹配以开头    ~/ 包含    !~取反
 [root@svr5 ~]# awk -F: '/^(root|adm)/{print $1,$3}' /etc/passwd  // |是或者  ^匹配以开头
 [root@svr5 ~]# awk -F: '$1~/root/' /etc/passwd //输出账户第1''列''包含root    ~/ 包含
 [root@svr5 ~]# awk -F: '$1!~/root/' /etc/passwd //输出账户第1''列''不包含root  !~取反
2）数值/字符串比较
==(等于)   !=（不等于）  >（大于）
>=（大于等于）  <（小于）  <=（小于等于）
不能直接用行号  NR变相使用行号
eg:[root@svr5 ~]# awk -F: 'NR==3{print}' /etc/passwd  //输出第3行（行号NR等于3）的用户记录
eg:[root@svr5 ~]# awk -F: '$3>=1000{print $1,$3}' /etc/passwd   //输出账户第3列UID大于等于1000的账户名称和UID信息
eg:[root@svr5 ~]# awk -F: '$1=="root"{print $1}' /etc/passwd   //（精确值的输出）
3）逻辑测试条件
 &&与   || 或 
eg:[root@svr5 ~]# awk -F: '$3>10 && $3<20' /etc/passwd
4）数学运算(常量或变量)
eg:[root@svr5 ~]# awk 'BEGIN{x++;print x}'    //变量可以不赋值
   [root@svr5 ~]# awk 'BEGIN{x=8;print x+=2}'
eg:[root@svr5 ~]# seq  200 | awk  '$1%3==0'       //找200以内3的倍数  seq 200 ===> {1..200} $1是只有一列

awk流程控制
awk过滤中的if分支结构
1）单分支   {if(判断){命令}}
eg:[root@svr5 ~]# awk -F: '{if($3<=1000){i++}}END{print i}' /etc/passwd  //统计/etc/passwd文件中UID小于或等于1000的用户个数
2）双分支   {if(判断){命令}else{命令}}
eg:[root@svr5 ~]# awk -F: '{if($3<=1000){i++}else{j++}}END{print i,j}' /etc/passwd  
     //分别统计/etc/passwd文件中UID小于或等于1000、UID大于1000的用户个数

awk数组
数组是一个可以存储多个值的变量
格式：数组名[下标]=元素值
调用数组：数组名[下标]
遍历数组的用法：for(变量 in 数组名){print 数组名[变量]}
eg:[root@svr5 ~]# awk 'BEGIN{a[0]=0;a[1]=11;a[2]=22; for(i in a){print i,a[i]}}'
    0 0     //第一个0为下标   第二个0为值
    1 11    //1为下标 11为值
    2 22   //2为下标 22为值
!!!awk数组的下标除了可以使用数字，也可以使用字符串，字符串需要使用双引号
eg:[root@svr5 ~]# awk 'BEGIN{a["hehe"]=11;print a["hehe"]}'

ab -c 100 -n 100000 http://172.25.0.11/   //100个人访问网站10万次

sort命令
-r:反序
-n:按数字顺序升序排列
-k:按第几个字段来排序

！！！！查看...显示了多少次（ip 用户 $1是一个变量）
awk '{ip[$1]++}END{for (i in ip){print ip[i],i}}' /var/log/httpd/access_log  | sort -n   //sort排序  -n升序 -nr  降序 











































   




































































































































































































































































