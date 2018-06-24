#!/usr/bin/sh


USERNAME="账号"
PASSWORD="密码"




function get_baiduid(){
curl -s -L https://passport.baidu.com/v2/ -A "Mozilla/5.0 (Linux; U; Android 7.1.2; zh-Hans-CN; ONEPLUS A5010 Build/NJH47F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 Quark/2.4.2.986 Mobile Safari/537.36" -c 1.cookie >/dev/null 2>&1
if [[ -e 1.cookie ]];then
if [[ "$(cat 1.cookie|grep BAIDUID)" != "" ]];then
return 0
else return 1;fi
else return 1;fi
}

function get_token(){
TOKEN="$(curl -s -L "http://passport.baidu.com/v2/api/?getapi&tpl=netdisk&apiver=v3&class=login&logintype=basicLogin&callback=Fuck" -A "Mozilla/5.0 (Linux; U; Android 7.1.2; zh-Hans-CN; ONEPLUS A5010 Build/NJH47F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 Quark/2.4.2.986 Mobile Safari/537.36" -b 1.cookie |tr "," "\n"|grep token|sed 's/token//g'|tr -cd '[0-9a-zA-Z]')"
if [[ "$TOKEN" != "" ]];then
return 0
else return 1;fi
}

function check_login(){
check_login_result="$(curl -s -b ./1.cookie -L "http://passport.baidu.com/v2/api/?logincheck&token=$TOKEN&tpl=pp&apiver=v3&sub_source=leadsetpwd&username=$USERNAME&loginversion=v4&traceid=&callback=Fuck" -c 1.cookie)"

CODESTRING="$(echo "$check_login_result"|grep codeString|tr "," "\n"|grep codeString|sed 's/codeString//g;s/data//g'|tr -cd '[0-9A-Za-z]')"
}


function login(){
login_result="$(curl -s -b ./1.cookie -L  -H 'Content-Type: application/x-www-form-urlencoded' "http://passport.baidu.com/v2/api/?login&u=https://pan.baidu.com/wap/home/" -A "Mozilla/5.0 (Linux; U; Android 7.1.2; zh-Hans-CN; ONEPLUS A5010 Build/NJH47F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 Quark/2.4.2.986 Mobile Safari/537.36" -d "staticpage=http://pan.baidu.com/res/static/thirdparty/pass_v3_jump.html&charset=utf-8&token=$TOKEN&tpl=netdisk&subpro=&apiver=v3&codestring=$CODESTRING&safeflg=0&u=http://pan.baidu.com/&isPhone=&quick_user=0&logintype=basicLogin&logLoginType=pc_loginBasic&idc=&loginmerge=true&username=$USERNAME&password=$PASSWORD&verifycode=$VERiFYCODE&mem_pass=on&rsakey=&crypttype=&tt=$(date +%s000)&ppui_logintime=2602&callback=parent.Fuck" -c ./1.cookie)"
if [[ "$login_result" != "" ]];then
if [[ "$(echo "$login_result"|grep err_no=0)" != "" ]];then
result=0
elif [[ "$(echo "$login_result"|grep err_no=257)" != "" ]];then
CODESTRING="$(echo "$login_result"|grep codeString=|tr "&" "\n"|grep codeString=|sed 's/codeString=//g')"
result=1
elif [[ "$(echo "$login_result"|grep err_no=6)" != "" ]];then
CODESTRING="$(echo "$login_result"|grep codeString=|tr "&" "\n"|grep codeString=|sed 's/codeString=//g')"
result=1
elif [[ "$(echo "$login_result"|grep err_no=120021)" != "" ]];then
AUTHTOKEN="$(echo "$login_result"|grep authtoken=|tr "&" "\n"|grep authtoken=|sed 's/authtoken=//g')"
LTOKEN="$(echo "$login_result"|grep ltoken=|tr "&" "\n"|grep ltoken=|sed 's/ltoken=//g')"
LSTR="$(echo "$login_result"|grep lstr=|tr "&" "\n"|grep lstr=|sed 's/lstr=//g')"
result=2
else result=3;fi
else result=3;fi

}

function get_capcha(){
curl -L "https://passport.baidu.com/cgi-bin/genimage?$CODESTRING" -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36" -b ./1.cookie >/sdcard/1.gif
}

function get_check_method(){
check_result="$(curl -s -b ./1.cookie -L "http://passport.baidu.com/v2/sapi/authwidgetverify?authtoken=$AUTHTOKEN&type=&jsonp=1&apiver=v3&verifychannel=&action=getapi&vcode=&questionAndAnswer=&tt=$(date +%s000)&needsid=&rsakey=&countrycode=&subpro=netdisk_web&callback=Fuck" -A "Mozilla/5.0 (Linux; U; Android 7.1.2; zh-Hans-CN; ONEPLUS A5010 Build/NJH47F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 Quark/2.4.2.986 Mobile Safari/537.36")"
echo "$check_result"
if [[ "$check_result" != "" ]];then
mobile="$(echo "$check_result"|tr "," "\n"| grep mobile|tr -cd "[0-9*]")"
email="$(echo "$check_result"|tr "," "\n"|grep email|grep -v original_email|sed 's/email//g'| tr -cd "[a-zA-Z0-9*.@]")"
if [[ "$mobile" != "" && "$email" == "" ]];then
method=1
elif [[ "$mobile" == "" && "$email" != "" ]];then
method=2
elif [[ "$mobile" != "" && "$email" != "" ]];then
method=3
else method=4;fi
else method=4;fi
}

function send_check_code(){
if [[ $1 == mobile ]];then
TYPE=mobile
elif [[ $1 == email ]];then
TYPE=email;fi
send_result="$(curl -s -b ./1.cookie -L "http://passport.baidu.com/v2/sapi/authwidgetverify?authtoken=$AUTHTOKEN&type=$TYPE&jsonp=1&apiver=v3&verifychannel=&action=send&vcode=&questionAndAnswer=&needsid=&rsakey=&countrycode=&subpro=&u=https%3A%2F%2Fpassport.baidu.com%2F&lstr=$LSTR&tt=$(date +%s000)&ltoken=$LTOKEN&tpl=pp&traceid=40E21601&callback=Fuck" -A "Mozilla/5.0 (Linux; U; Android 7.1.2; zh-Hans-CN; ONEPLUS A5010 Build/NJH47F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 Quark/2.4.2.986 Mobile Safari/537.36")"
if [[ "$send_result" != "" ]];then
if [[ "$(echo "$send_result"|grep 110000)" != "" ]];then
code_send_result=1
else code_send_result=2;fi
else code_send_result=2;fi
}

function check_check_code(){
VCODE=$1
check_result="$(curl -s -b ./1.cookie -L -H "Connection: keep-alive" -H "Referer: http://passport.baidu.com/v2/" "http://passport.baidu.com/v2/sapi/authwidgetverify?authtoken=$AUTHTOKEN&type=$TYPE&jsonp=1&apiver=v3&verifychannel=&action=check&vcode=$VCODE&questionAndAnswer=&needsid=&rsakey=&countrycode=&subpro=&u=https%3A%2F%2Fpassport.baidu.com%2F&lstr=$LSTR&ltoken=$LTOKEN&tt=$(date +%s000)&tpl=pp&secret=&traceid=40E21601&callback=Fuck" -A "Mozilla/5.0 (Linux; U; Android 7.1.2; zh-Hans-CN; ONEPLUS A5010 Build/NJH47F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 Quark/2.4.2.986 Mobile Safari/537.36" -c 1.cookie)" 
if [[ "$check_result" != "" ]];then
if [[ "$(echo "$check_result"|grep 110000)" != "" ]];then
TRACEID="$(echo "$check_result"|tr "," "\n"|grep traceid|sed 's/traceid//g'| tr -cd "[a-zA-Z0-99]")"
code_check_result=1
else code_check_result=2;fi
else code_check_result=2;fi
}

function login_after_check(){
last_login_result="$(curl -s -b ./1.cookie -L -H "Connection: keep-alive"  -H 'Content-Type: application/x-www-form-urlencoded' -H "Referer: http://passport.baidu.com/v2/" "https://passport.baidu.com/v2/?loginproxy&u=https%3A%2F%pan.baidu.com%2F&tpl=pp&ltoken=$LTOKEN&lstr=$LSTR&traceid=&apiver=v3&tt=$(date +%s000)&traceid=&callback=Fuck" -A "Mozilla/5.0 (Linux; U; Android 7.1.2; zh-Hans-CN; ONEPLUS A5010 Build/NJH47F) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 Quark/2.4.2.986 Mobile Safari/537.36" -c 1.cookie)" 
}

get_baiduid
if [[ "$?" == 1 ]];then
echo 'Failed to get baiduid';fi

get_token
if [[ "$?" == 1 ]];then
echo 'Failed to get token';fi

check_login
function start_login(){
login
if [[ "$result" == 0 ]];then
echo 'Login successful'
elif [[ "$result" == 1 ]];then
echo -e -n "Captcha check required\nVisit\n\nhttps://passport.baidu.com/cgi-bin/genimage?$CODESTRING\n\nIn your browser to read captcha\n\nCaptcha:"
read VERiFYCODE
if [[ "$VERiFYCODE" != "" ]];then start_login
else echo "Login gave up";fi
elif [[ "$result" == 2 ]];then
get_check_method
echo "Identity check required"
if [[ $method == 1 ]];then
echo "Enter 1 to confirm to require message check from $mobile"
elif [[ $method == 2 ]];then
echo "Enter 1 to confirm to require message check from $email"
elif [[ $method == 3 ]];then
echo "Enter 1/2 to confirm to require message check from $mobile/$email";fi
read command
if [[ $command == 1 ]];then
if [[ $method == 1 ]];then
send_check_code mobile
elif [[ $method == 2 ]];then
send_check_code email
elif [[ $method == 3 ]];then
send_check_code mobile
else echo "Unknown failure";fi
elif [[ $command == 2 ]];then
if [[ $method == 3 ]];then
send_check_code email
else echo "Unknown failure";fi
else echo "Login gave up";fi
if [[ $code_send_result == 1 ]];then
echo "Enter the verify code you received from your phone/email"
read command
if [[ $command != "" ]];then
check_check_code $command
else echo "Login gave up";fi;fi
if [[ "$code_check_result" == 1 ]];then
login_after_check
echo "Try to relogin";fi
fi

}

start_login




