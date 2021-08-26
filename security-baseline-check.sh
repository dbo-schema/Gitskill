#! /bin/bash 
#vesion 1.0

#获取IP地址
ipadd=`ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk  '{print $2}' | egrep -o "192\.168\.(0|1|2|3|8|140|128|136|8|220|221|223)\.[0-9]{1,3}" `

cat <<EOF
*************************************************************************************
*****               linux基线检查脚本                 			        *****
*****               输出结果"/home/pttl/${ipadd}_checkResult.txt"            *****
*************************************************************************************
EOF

echo "IP: ${ipadd}" | tee -a "/home/pttl/${ipadd}_checkResult.txt"

user_id=`whoami`
echo "当前扫描用户：${user_id}" | tee -a "/home/pttl/${ipadd}_checkResult.txt"

scanner_time=`date '+%Y-%m-%d %H:%M:%S'`
echo "当前扫描时间：${scanner_time}" | tee -a "/home/pttl/${ipadd}_checkResult.txt"


echo -e "\n"
#检查口令更改日期
checkPassmax=`cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v ^# | awk '{print $2}'`
checkPassmin=`cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v ^# | awk '{print $2}'`
checkPasslen=`cat /etc/login.defs | grep PASS_MIN_LEN | grep -v ^# | awk '{print $2}'`
checkPassage=`cat /etc/login.defs | grep PASS_WARN_AGE | grep -v ^# | awk '{print $2}'`

echo "第一项 检查口令更改日期:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
if [ $checkPassmax -le 90 -a $checkPassmax -gt 0 ];then
  echo -e "\033[1;32m Y:口令生存周期为${checkPassmax}天，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:口令生存周期为${checkPassmax}天，不符合要求,建议设置不大于90天 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

if [ $checkPassmin -ge 2 ];then
  echo -e "\033[1;32m Y:口令更改最小时间间隔为${checkPassmin}天，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:口令更改最小时间间隔为${checkPassmin}天，不符合要求，建议设置大于等于2天 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

if [ $checkPasslen -ge 8 ];then
  echo -e "\033[1;32m Y:口令最小长度为${checkPasslen},符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:口令最小长度为${checkPasslen},不符合要求，建议设置最小长度大于等于8 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

if [ $checkPassage -ge 30 -a $checkPassage -lt $checkPassage ];then
  echo -e "\033[1;32m Y:口令过期警告时间天数为${checkPassage},符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:口令过期警告时间天数为${checkPassage},不符合要求，建议设置大于等于30并小于口令生存周期 \033[0m" | tee -a /"/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查账户是否会主动注销
echo "第二项 检查账户是否会主动注销:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkTimeout=$(cat /etc/profile | grep TMOUT)
if [ $? -eq 0 ];then
  TMOUT=`cat /etc/profile | grep TMOUT | awk -F[=] '{print $2}'`
  if [ $TMOUT -le 600 -a $TMOUT -ge 10 ];then
    echo -e "\033[1;32m Y:账号超时时间${TMOUT}秒,符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
  else
    echo -e "\033[1;31m N:账号超时时间${TMOUT}秒,不符合要求，建议设置小于600秒 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
  fi
else
  echo -e "\033[1;31m N:账号超时不存在自动注销,不符合要求，建议设置小于600秒 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查历史命令保留行数
echo "第三项 检查历史命令保留行数:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkHistsize=$(cat /etc/profile | grep HISTSIZE)
if [ $? -eq 0 ];then
  HISTSIZE=`cat /etc/profile | grep HISTSIZE | awk -F[=] '{print $2}'`
  if [ $HISTSIZE -eq 5 ];then
    echo -e "\033[1;32m Y:HISTSIZE显示行数为${HISTSIZE}行,符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
  else
    echo -e "\033[1;31m N:HISTSIZE显示行数为${HISTSIZE}行,不符合要求，建议设置为5行 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
  fi
else
  echo -e "\033[1;31m N:HISTSIZE显示行数不存在,不符合要求，建议设置为5行 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkHistFileSize=$(cat /etc/profile | grep HISTFILESIZE)
if [ $? -eq 0 ];then
  HISTFILESIZE=`cat /etc/profile | grep HISTFILESIZE | awk -F[=] '{print $2}'`
  if [ $HISTFILESIZE -eq 5 ];then
    echo -e "\033[1;32m Y:HISTFILESIZE显示行数为${HISTFILESIZE}行,符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
  else
    echo -e "\033[1;31m N:HISTFILESIZE显示行数为${HISTFILESIZE}行,不符合要求，建议设置为5行 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
  fi
else
  echo -e "\033[1;31m N:HISTFILESIZE显示行数不存在,不符合要求，建议设置为5行 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查root用户是否能远程登录限制
echo "第四项 检查root用户远程登录限制:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkPermitRootLogin=$(cat /etc/ssh/sshd_config | grep -v ^# | grep "PermitRootLogin no")
if [ $? -eq 0 ];then
  echo -e "\033[1;32m Y:已经设置远程root不能登陆，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:已经设置远程root能登陆，不符合要求，建议/etc/ssh/sshd_config添加PermitRootLogin no \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkProtocol=$(cat /etc/ssh/sshd_config | grep -v ^# | grep "Protocol 2")
if [ $? -eq 0 ];then
  echo -e "\033[1;32m Y:已经设置Protocol 2，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未设置Protocol 2，不符合要求，建议/etc/ssh/sshd_config添加Protocol 2 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkMaxAuthTries=$(cat /etc/ssh/sshd_config | grep -v ^# | grep "MaxAuthTries 3")
if [ $? -eq 0 ];then
  echo -e "\033[1;32m Y:已经设置MaxAuthTries 3，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未设置MaxAuthTries 3，不符合要求，建议/etc/ssh/sshd_config添加MaxAuthTries 3 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查UID为0的特权账号
echo "第五项 检查UID为0的特权账号:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkUid=`awk -F[:] 'NR!=1{print $3}' /etc/passwd`
flag=0
for i in $checkUid
do
  if [ $i = 0 ];then
    echo -e "\033[1;31m N:存在非root账号的账号UID为0，不符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
  else
    flag=1
  fi
done
if [ $flag = 1 ];then
  echo -e "\033[1;32m Y:不存在非root账号的账号UID为0，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查UID为0的特权账号
echo "第六项 检查.rhosts文件:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkRhosts=$(find / -name .rhosts)
if [ $? -eq 0 ];then
  echo -e "\033[1;32m Y:.rhosts文件不存在，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:.rhosts文件存在，不符合要求，建议修改配置文件，正确进行授权 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查umask值
echo "第七项 检查umask值:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkUmaskp=`cat /etc/profile | grep umask | grep -v ^# | awk '{print $2}'`
checkUmaskc=`cat /etc/csh.cshrc | grep umask | grep -v ^# | awk '{print $2}'`
checkUmaskb=`cat /etc/bashrc | grep umask | grep -v ^# | awk 'NR!=1{print $2}'`
flags=0
for i in $checkUmaskp
do
  if [ $i != "077" ];then
    echo -e "\033[1;31m N:/etc/profile文件中所所设置的umask为${i},不符合要求，建议设置为077 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
    flags=1
    break
  fi
done
if [ $flags == 0 ];then
  echo -e "\033[1;32m Y:/etc/profile文件中所设置的umask为${i},符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi 
flags=0
for i in $checkUmaskc
do
  if [ $i != "077" ];then
    echo -e "\033[1;31m N:/etc/csh.cshrc文件中所所设置的umask为${i},不符合要求，建议设置为077 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
    flags=1
    break
  fi
done  
if [ $flags == 0 ];then
  echo -e "\033[1;32m Y:/etc/csh.cshrc文件中所设置的umask为${i},符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
flags=0
for i in $checkUmaskb
do
  if [ $i != "077" ];then
    echo -e "\033[1;31m N:/etc/bashrc文件中所设置的umask为${i},不符合要求，建议设置为077 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
    flags=1
    break
  fi
done
if [ $flags == 0 ];then
  echo -e "\033[1;32m Y:/etc/bashrc文件中所设置的umask为${i},符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查重要文件目录权限
echo "第八项 检查重要文件目录权限:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkFileSecurity=`ls -ld /etc/security | awk '{print $1}'`
checkFileShadow=`ls -l /etc/shadow | awk '{print $1}'`
checkFilePasswd=`ls -l /etc/passwd | awk '{print $1}'`
checkFileGroup=`ls -l /etc/group | awk '{print $1}'`
checkFileServices=`ls -ld /etc/services | awk '{print $1}'`
checkFileRc3=`ls -ld /etc/rc3.d/ | awk '{print $1}'`
checkFileRc6=`ls -ld /etc/rc6.d/ | awk '{print $1}'`
checkFileRc5=`ls -ld /etc/rc5.d/ | awk '{print $1}'`
checkFileRc1=`ls -ld /etc/rc1.d/ | awk '{print $1}'`
checkFileRc4=`ls -ld /etc/rc4.d/ | awk '{print $1}'`
checkFileRc0=`ls -ld /etc/rc0.d/ | awk '{print $1}'`
checkFileRc2=`ls -ld /etc/rc2.d/ | awk '{print $1}'`
checkFileInit=`ls -ld /etc/init.d/ | awk '{print $1}'`
#检测文件权限为600的文件
if [ $checkFileSecurity = "drw-------." ];then
  echo -e "\033[1;32m Y:/etc/security文件权限为600，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/security文件权限不为600，不符合要求，建议设置权限为600 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileShadow = "-rw-------" ];then
  echo -e "\033[1;32m Y:/etc/shadow文件权限为600，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/shadow文件权限不为600，不符合要求，建议设置权限为600 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

#检测文件权限为644的文件
if [ $checkFilePasswd = "-rw-r--r--" ];then
  echo -e "\033[1;32m Y:/etc/passwd文件权限为644，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/passwd文件权限不为644，不符合要求，建议设置权限为644 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileGroup = "-rw-r--r--" ];then
  echo -e "\033[1;32m Y:/etc/group文件权限为644，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/group文件权限不为644，不符合要求，建议设置权限为644 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileServices = "-rw-r--r--." ];then
  echo -e "\033[1;32m Y:/etc/services文件权限为644，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/services文件权限不为644，不符合要求，建议设置权限为644 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

#检测文件权限为750的文件
if [ $checkFileRc3 = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/rc3.d文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/rc3.d文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileRc6 = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/rc6.d文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/rc6.d文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileRc5 = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/rc5.d文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/rc5.d文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileRc1 = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/rc1.d文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/rc1.d文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileRc4 = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/rc4.d文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/rc4.d文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileRc0 = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/rc0.d文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/rc0.d文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileRc2 = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/rc2.d文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/rc2.d文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
if [ $checkFileInit = "drwxr-x---." ];then
  echo -e "\033[1;32m Y:/etc/init.d/文件权限为750，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:/etc/init.d/文件权限不为750，不符合要求，建议设置权限为750 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查无用账户是否禁用
echo "第九项 检查无用账户是否禁用:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkSync=`cat /etc/passwd | grep sync | grep -v ^# | awk -F[/] '{print $5}'`
checkHalt=`cat /etc/passwd | grep halt | grep -v ^# | awk -F[/] '{print $5}'`
checkShutdown=`cat /etc/passwd | grep shutdown | grep -v ^# | awk -F[/] '{print $5}'`

if [ $checkSync = "nologin" ];then
  echo -e "\033[1;32m Y:sync账户已禁用，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:sync账户未禁用，不符合要求,建议禁用sync账户 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

if [ $checkHalt = "nologin" ];then
  echo -e "\033[1;32m Y:halt账户已禁用，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:halt账户未禁用，不符合要求,建议禁用halt账户 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

if [ $checkShutdown = "nologin" ];then
  echo -e "\033[1;32m Y:shutdown账户已禁用，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:shutdown账户未禁用，不符合要求,建议禁用shutdown账户 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi
#输出未禁用账户供人为判断
for checkUsername in $(awk -F[:] '{if($7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin") print $1}' /etc/passwd)
do
    echo -e "\033[1;33m S:存在未禁用账号$checkUsername，请人为判断是否需要禁用 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
done


echo -e "\n"
#检查Talnet远程登录
echo "第十项 检查Talnet远程登录:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkTalnet=`cat /etc/pam.d/login | egrep "auth\s+required\s+pam_securetty.so" | grep -v ^# `
if [ $? -eq 0 ];then
  echo -e "\033[1;32m Y:已经禁用Talnet远程登录，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未禁用Talnet远程登录，不符合要求，建议禁用Talnet远程登录 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查密码重复使用次数
echo "第十一项 检查密码重复使用次数:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkPassword=`cat /etc/pam.d/system-auth | egrep "password\s+sufficient.*remember=5" | grep -v ^# `
if [ $? -eq 0 ];then
  echo -e "\033[1;32m Y:已经设置密码重复使用次数5次，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未设置密码重复使用次数，不符合要求，建议设置为5次 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查是否禁用别名文件
echo "第十二项 检查是否禁用别名文件:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkGames=`cat /etc/aliases | egrep "games" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释games别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释games别名，不符合要求，建议注释games别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkIngres=`cat /etc/aliases | egrep "ingres" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释ingres别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释ingres别名，不符合要求，建议注释ingres别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkSystem=`cat /etc/aliases | egrep "system" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释system别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释system别名，不符合要求，建议注释system别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkToor=`cat /etc/aliases | egrep "toor" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释toor别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释toor别名，不符合要求，建议注释toor别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkUucp=`cat /etc/aliases | egrep "uucp" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释uucp别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释uucp别名，不符合要求，建议注释uucp别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkManager=`cat /etc/aliases | egrep "manager" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释manager别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释manager别名，不符合要求，建议注释manager别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkDumper=`cat /etc/aliases | egrep "dumper" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释dumper别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释dumper别名，不符合要求，建议注释dumper别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkOperator=`cat /etc/aliases | egrep "operator" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释operator别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释operator别名，不符合要求，建议注释operator别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkDecode=`cat /etc/aliases | egrep "decode" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释decode别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释decode别名，不符合要求，建议注释decode别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkRoot=`cat /etc/aliases | egrep "root.*marc" | grep -v ^# `
if [ $? -ne 0 ];then
  echo -e "\033[1;32m Y:已经注释root别名，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未注释root别名，不符合要求，建议注释root别名 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查SNMP团体字
echo "第十三项 检查SNMP团体字:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkSnmp=`cat /etc/snmp/snmpd.conf | egrep "com2sec" | grep -v ^# | awk '{print $4}'`
if [ $checkSnmp = "public" -a $checkSnmp = "private" ];then
  echo -e "\033[1;31m Y:未更改SNMP默认团体字$checkSnmp，不符合要求，建议修改为read@servinfo \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;32m N:已更改SNMP默认团体字$checkSnmp，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查口令复杂度
echo "第十四项 检查口令复杂度:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkMinlen=`cat /etc/pam.d/system-auth |egrep "password\s+requisite pam_cracklib.so\s+minlen=8\s+lcredit=-1\s+dcredit=-1\s+ocredit=-1" | grep -v ^# `
if [ $? -eq "0" ];then
  echo -e "\033[1;32m Y:已经配置口令复杂度$checkMinlen，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未配置口令复杂度，不符合要求，建议配置口令复杂度 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查空口令
echo "第十五项 检查空口令:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkNullUsername=0
for checkNullUsername in $(awk -F[:] '{if($2 == "" ) print $1}' /etc/shadow)
do
    echo -e "\033[1;31m N:存在空口令账号$checkNullUsername，不符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
done
if [ $checkNullUsername -eq 0 ];then
echo -e "\033[1;32m Y:不存在空口令账号，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查sshd账户认证失败次数限制
echo "第十五项 检查sshd账户认证失败次数限制:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkSshdAuth=`cat /etc/pam.d/sshd | grep unlock_time | grep -v ^# | awk '{print$4,$5}' | tr '=' ' '| awk '{if($2 <= 5 && $4 >= 300) {print 0}}'`
if [ $checkSshdAuth = "0" ];then
  echo -e "\033[1;32m Y:已经配置Auth认证失败次数限制，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未配置Auth认证失败次数限制，不符合要求，建议配置Auth认证失败次数限制 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkSshdAcount=`cat /etc/pam.d/sshd |egrep "account\s+required\s+pam_tally2.so" | grep -v ^# `
if [ $? -eq "0" ];then
  echo -e "\033[1;32m Y:已经配置Acount认证失败次数限制$checkSshdAcount，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未配置Acount认证失败次数限制，不符合要求，建议配置Acount认证失败次数限制 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查system-auth账户认证失败次数限制
echo "第十六项 检查system-auth账户认证失败次数限制:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkSystemAuth=`cat /etc/pam.d/system-auth | grep unlock_time | grep -v ^# | awk '{print$4,$5}' | tr '=' ' '| awk '{if($2 <= 5 && $4 >= 300) {print 1}}'`
if [ $checkSystemAuth = "1" ];then
  echo -e "\033[1;32m Y:已经配置Auth认证失败次数限制，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未配置Auth认证失败次数限制，不符合要求，建议配置Auth认证失败次数限制 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi

checkSystemAcount=`cat /etc/pam.d/system-auth |egrep "account\s+required\s+pam_tally2.so" | grep -v ^# `
if [ $? -eq "0" ];then
  echo -e "\033[1;32m Y:已经配置Acount认证失败次数限制$checkSshdAcount，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未配置Acount认证失败次数限制，不符合要求，建议配置Acount认证失败次数限制 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查杀毒软件
echo "第十七项 检查杀毒软件:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkDs_agent=$(lsof -i:4118)
if [ $? -eq 0 ];then
  echo -e "\033[1;32m Y:已经设置杀毒软件，符合要求 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
else
  echo -e "\033[1;31m N:未设置杀毒软件，不符合要求，建议设置杀毒软件 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
fi


echo -e "\n"
#检查openssh、openssl版本
echo "第十八项 检查openssh、openssl版本:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
checkOpenssh=$(ssh -V 2>&1)
  echo -e "\033[1;33m S:SSH版本:$checkOpenssh，请人为判断是否为最新版 \033[0m" | tee -a "/home/pttl/${ipadd}_checkResult.txt"



echo -e "\n"
#检查linux内核版本
echo "第十九项 检查linux内核版本:" | tee -a "/home/pttl/${ipadd}_checkResult.txt"
# Copyright (C) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

VERSION="1.0"

# Warning! Be sure to download the latest version of this script from its primary source:

ARTICLE="https://access.redhat.com/security/vulnerabilities/tcpsack"

# DO NOT blindly trust any internet sources and NEVER do `curl something | bash`!

# This script is meant for simple detection of the vulnerability. Feel free to modify it for your
# environment or needs. For more advanced detection, consider Red Hat Insights:
# https://access.redhat.com/products/red-hat-insights#getstarted

# Checking against the list of vulnerable packages is necessary because of the way how features
# are back-ported to older versions of packages in various channels.

VULNERABLE_KERNELS=(
	 '2.6.18-8.el5' '2.6.18-8.1.1.el5' '2.6.18-8.1.3.el5' '2.6.18-8.1.4.el5' '2.6.18-8.1.6.el5'
	 '2.6.18-8.1.8.el5' '2.6.18-8.1.10.el5' '2.6.18-8.1.14.el5' '2.6.18-8.1.15.el5' '2.6.18-53.el5'
	 '2.6.18-53.1.4.el5' '2.6.18-53.1.6.el5' '2.6.18-53.1.13.el5' '2.6.18-53.1.14.el5' '2.6.18-53.1.19.el5'
	 '2.6.18-53.1.21.el5' '2.6.18-92.el5' '2.6.18-92.1.1.el5' '2.6.18-92.1.6.el5' '2.6.18-92.1.10.el5'
	 '2.6.18-92.1.13.el5' '2.6.18-92.1.17.el5' '2.6.18-92.1.18.el5' '2.6.18-92.1.22.el5' '2.6.18-128.el5'
	 '2.6.18-128.1.1.el5' '2.6.18-128.1.6.el5' '2.6.18-128.1.10.el5' '2.6.18-128.1.14.el5' '2.6.18-128.1.16.el5'
	 '2.6.18-128.2.1.el5' '2.6.18-128.4.1.el5' '2.6.18-128.7.1.el5' '2.6.18-164.el5' '2.6.18-164.2.1.el5'
	 '2.6.18-164.6.1.el5' '2.6.18-164.9.1.el5' '2.6.18-164.10.1.el5' '2.6.18-164.11.1.el5' '2.6.18-164.15.1.el5'
	 '2.6.18-194.el5' '2.6.18-194.3.1.el5' '2.6.18-194.8.1.el5' '2.6.18-194.11.1.el5' '2.6.18-194.11.3.el5'
	 '2.6.18-194.11.4.el5' '2.6.18-194.17.1.el5' '2.6.18-194.17.4.el5' '2.6.18-194.26.1.el5' '2.6.18-194.32.1.el5'
	 '2.6.18-238.el5' '2.6.18-238.1.1.el5' '2.6.18-238.5.1.el5' '2.6.18-238.9.1.el5' '2.6.18-238.12.1.el5'
	 '2.6.18-238.19.1.el5' '2.6.18-238.21.1.el5' '2.6.18-238.27.1.el5' '2.6.18-238.28.1.el5' '2.6.18-238.31.1.el5'
	 '2.6.18-238.33.1.el5' '2.6.18-238.35.1.el5' '2.6.18-238.37.1.el5' '2.6.18-238.39.1.el5' '2.6.18-238.40.1.el5'
	 '2.6.18-238.44.1.el5' '2.6.18-238.45.1.el5' '2.6.18-238.47.1.el5' '2.6.18-238.48.1.el5' '2.6.18-238.49.1.el5'
	 '2.6.18-238.50.1.el5' '2.6.18-238.51.1.el5' '2.6.18-238.52.1.el5' '2.6.18-238.53.1.el5' '2.6.18-238.54.1.el5'
	 '2.6.18-238.55.1.el5' '2.6.18-238.56.1.el5' '2.6.18-238.57.1.el5' '2.6.18-238.58.1.el5' '2.6.18-274.el5'
	 '2.6.18-274.3.1.el5' '2.6.18-274.7.1.el5' '2.6.18-274.12.1.el5' '2.6.18-274.17.1.el5' '2.6.18-274.18.1.el5'
	 '2.6.18-308.el5' '2.6.18-308.1.1.el5' '2.6.18-308.4.1.el5' '2.6.18-308.8.1.el5' '2.6.18-308.8.2.el5'
	 '2.6.18-308.11.1.el5' '2.6.18-308.13.1.el5' '2.6.18-308.16.1.el5' '2.6.18-308.20.1.el5' '2.6.18-308.24.1.el5'
	 '2.6.18-339.el5' '2.6.18-348.el5' '2.6.18-348.1.1.el5' '2.6.18-348.2.1.el5' '2.6.18-348.3.1.el5'
	 '2.6.18-348.4.1.el5' '2.6.18-348.6.1.el5' '2.6.18-348.12.1.el5' '2.6.18-348.16.1.el5' '2.6.18-348.18.1.el5'
	 '2.6.18-348.19.1.el5' '2.6.18-348.21.1.el5' '2.6.18-348.22.1.el5' '2.6.18-348.23.1.el5' '2.6.18-348.25.1.el5'
	 '2.6.18-348.27.1.el5' '2.6.18-348.28.1.el5' '2.6.18-348.29.1.el5' '2.6.18-348.30.1.el5' '2.6.18-348.31.2.el5'
	 '2.6.18-348.32.1.el5' '2.6.18-348.33.1.el5' '2.6.18-348.33.2.el5' '2.6.18-348.34.1.el5' '2.6.18-348.34.2.el5'
	 '2.6.18-348.35.1.el5' '2.6.18-348.39.1.el5' '2.6.18-348.39.2.el5' '2.6.18-348.40.1.el5' '2.6.18-348.41.1.el5'
	 '2.6.18-348.42.1.el5' '2.6.18-348.43.1.el5' '2.6.18-371.el5' '2.6.18-371.1.2.el5' '2.6.18-371.3.1.el5'
	 '2.6.18-371.4.1.el5' '2.6.18-371.6.1.el5' '2.6.18-371.8.1.el5' '2.6.18-371.9.1.el5' '2.6.18-371.11.1.el5'
	 '2.6.18-371.12.1.el5' '2.6.18-391.el5' '2.6.18-398.el5' '2.6.18-400.el5' '2.6.18-400.1.1.el5'
	 '2.6.18-402.el5' '2.6.18-404.el5' '2.6.18-406.el5' '2.6.18-407.el5' '2.6.18-408.el5'
	 '2.6.18-409.el5' '2.6.18-410.el5' '2.6.18-411.el5' '2.6.18-412.el5' '2.6.18-416.el5'
	 '2.6.18-417.el5' '2.6.18-418.el5' '2.6.18-419.el5' '2.6.18-420.el5' '2.6.18-422.el5'
	 '2.6.18-423.el5' '2.6.18-426.el5' '2.6.18-430.el5' '2.6.18-431.el5' '2.6.18-433.el5'
	 '2.6.18-434.el5' '2.6.18-436.el5' '2.6.18-437.el5' '2.6.32-71.el6' '2.6.32-71.7.1.el6'
	 '2.6.32-71.14.1.el6' '2.6.32-71.18.1.el6' '2.6.32-71.18.2.el6' '2.6.32-71.24.1.el6' '2.6.32-71.29.1.el6'
	 '2.6.32-131.0.15.el6' '2.6.32-131.2.1.el6' '2.6.32-131.4.1.el6' '2.6.32-131.6.1.el6' '2.6.32-131.12.1.el6'
	 '2.6.32-131.17.1.el6' '2.6.32-131.21.1.el6' '2.6.32-131.22.1.el6' '2.6.32-131.25.1.el6' '2.6.32-131.26.1.el6'
	 '2.6.32-131.28.1.el6' '2.6.32-131.29.1.el6' '2.6.32-131.30.1.el6' '2.6.32-131.30.2.el6' '2.6.32-131.33.1.el6'
	 '2.6.32-131.35.1.el6' '2.6.32-131.36.1.el6' '2.6.32-131.37.1.el6' '2.6.32-131.38.1.el6' '2.6.32-131.39.1.el6'
	 '2.6.32-220.el6' '2.6.32-220.2.1.el6' '2.6.32-220.4.1.el6' '2.6.32-220.4.2.el6' '2.6.32-220.4.4.bgq.el6'
	 '2.6.32-220.4.7.bgq.el6' '2.6.32-220.7.1.el6' '2.6.32-220.7.2.p7ih.el6' '2.6.32-220.7.3.p7ih.el6' '2.6.32-220.7.4.p7ih.el6'
	 '2.6.32-220.7.6.p7ih.el6' '2.6.32-220.7.7.p7ih.el6' '2.6.32-220.13.1.el6' '2.6.32-220.17.1.el6' '2.6.32-220.23.1.el6'
	 '2.6.32-220.24.1.el6' '2.6.32-220.25.1.el6' '2.6.32-220.26.1.el6' '2.6.32-220.28.1.el6' '2.6.32-220.30.1.el6'
	 '2.6.32-220.31.1.el6' '2.6.32-220.32.1.el6' '2.6.32-220.34.1.el6' '2.6.32-220.34.2.el6' '2.6.32-220.38.1.el6'
	 '2.6.32-220.39.1.el6' '2.6.32-220.41.1.el6' '2.6.32-220.42.1.el6' '2.6.32-220.45.1.el6' '2.6.32-220.46.1.el6'
	 '2.6.32-220.48.1.el6' '2.6.32-220.51.1.el6' '2.6.32-220.52.1.el6' '2.6.32-220.53.1.el6' '2.6.32-220.54.1.el6'
	 '2.6.32-220.55.1.el6' '2.6.32-220.56.1.el6' '2.6.32-220.57.1.el6' '2.6.32-220.58.1.el6' '2.6.32-220.60.2.el6'
	 '2.6.32-220.62.1.el6' '2.6.32-220.63.2.el6' '2.6.32-220.64.1.el6' '2.6.32-220.65.1.el6' '2.6.32-220.66.1.el6'
	 '2.6.32-220.67.1.el6' '2.6.32-220.68.1.el6' '2.6.32-220.69.1.el6' '2.6.32-220.70.1.el6' '2.6.32-220.71.1.el6'
	 '2.6.32-220.72.2.el6' '2.6.32-220.73.1.el6' '2.6.32-220.75.1.el6' '2.6.32-220.76.1.el6' '2.6.32-220.76.2.el6'
	 '2.6.32-220.77.1.el6' '2.6.32-279.el6' '2.6.32-279.1.1.el6' '2.6.32-279.2.1.el6' '2.6.32-279.5.1.el6'
	 '2.6.32-279.5.2.el6' '2.6.32-279.9.1.el6' '2.6.32-279.11.1.el6' '2.6.32-279.14.1.bgq.el6' '2.6.32-279.14.1.el6'
	 '2.6.32-279.19.1.el6' '2.6.32-279.22.1.el6' '2.6.32-279.23.1.el6' '2.6.32-279.25.1.el6' '2.6.32-279.25.2.el6'
	 '2.6.32-279.31.1.el6' '2.6.32-279.33.1.el6' '2.6.32-279.34.1.el6' '2.6.32-279.37.2.el6' '2.6.32-279.39.1.el6'
	 '2.6.32-279.41.1.el6' '2.6.32-279.42.1.el6' '2.6.32-279.43.1.el6' '2.6.32-279.43.2.el6' '2.6.32-279.46.1.el6'
	 '2.6.32-358.el6' '2.6.32-358.0.1.el6' '2.6.32-358.2.1.el6' '2.6.32-358.6.1.el6' '2.6.32-358.6.2.el6'
	 '2.6.32-358.6.3.p7ih.el6' '2.6.32-358.11.1.bgq.el6' '2.6.32-358.11.1.el6' '2.6.32-358.14.1.el6' '2.6.32-358.18.1.el6'
	 '2.6.32-358.23.2.el6' '2.6.32-358.28.1.el6' '2.6.32-358.32.3.el6' '2.6.32-358.37.1.el6' '2.6.32-358.41.1.el6'
	 '2.6.32-358.44.1.el6' '2.6.32-358.46.1.el6' '2.6.32-358.46.2.el6' '2.6.32-358.48.1.el6' '2.6.32-358.49.1.el6'
	 '2.6.32-358.51.1.el6' '2.6.32-358.51.2.el6' '2.6.32-358.55.1.el6' '2.6.32-358.56.1.el6' '2.6.32-358.59.1.el6'
	 '2.6.32-358.61.1.el6' '2.6.32-358.62.1.el6' '2.6.32-358.65.1.el6' '2.6.32-358.67.1.el6' '2.6.32-358.68.1.el6'
	 '2.6.32-358.69.1.el6' '2.6.32-358.70.1.el6' '2.6.32-358.71.1.el6' '2.6.32-358.72.1.el6' '2.6.32-358.73.1.el6'
	 '2.6.32-358.75.1.el6' '2.6.32-358.76.1.el6' '2.6.32-358.77.1.el6' '2.6.32-358.78.1.el6' '2.6.32-358.79.1.el6'
	 '2.6.32-358.79.2.el6' '2.6.32-358.81.1.el6' '2.6.32-358.82.1.el6' '2.6.32-358.83.1.el6' '2.6.32-358.84.1.el6'
	 '2.6.32-358.84.2.el6' '2.6.32-358.85.1.el6' '2.6.32-358.87.1.el6' '2.6.32-358.88.2.el6' '2.6.32-358.88.4.el6'
	 '2.6.32-358.90.1.el6' '2.6.32-358.91.4.el6' '2.6.32-358.93.1.el6' '2.6.32-358.94.1.el6' '2.6.32-358.95.1.el6'
	 '2.6.32-358.111.1.openstack.el6' '2.6.32-358.114.1.openstack.el6' '2.6.32-358.118.1.openstack.el6' '2.6.32-358.123.4.openstack.el6' '2.6.32-431.el6'
	 '2.6.32-431.1.1.bgq.el6' '2.6.32-431.1.2.el6' '2.6.32-431.3.1.el6' '2.6.32-431.5.1.el6' '2.6.32-431.11.2.el6'
	 '2.6.32-431.17.1.el6' '2.6.32-431.20.3.el6' '2.6.32-431.20.5.el6' '2.6.32-431.23.3.el6' '2.6.32-431.29.2.el6'
	 '2.6.32-431.37.1.el6' '2.6.32-431.40.1.el6' '2.6.32-431.40.2.el6' '2.6.32-431.46.2.el6' '2.6.32-431.50.1.el6'
	 '2.6.32-431.53.2.el6' '2.6.32-431.56.1.el6' '2.6.32-431.59.1.el6' '2.6.32-431.61.2.el6' '2.6.32-431.64.1.el6'
	 '2.6.32-431.66.1.el6' '2.6.32-431.68.1.el6' '2.6.32-431.69.1.el6' '2.6.32-431.70.1.el6' '2.6.32-431.71.1.el6'
	 '2.6.32-431.72.1.el6' '2.6.32-431.73.2.el6' '2.6.32-431.74.1.el6' '2.6.32-431.75.1.el6' '2.6.32-431.76.1.el6'
	 '2.6.32-431.77.1.el6' '2.6.32-431.78.1.el6' '2.6.32-431.79.1.el6' '2.6.32-431.80.1.el6' '2.6.32-431.80.2.el6'
	 '2.6.32-431.81.2.el6' '2.6.32-431.81.3.el6' '2.6.32-431.82.1.el6' '2.6.32-431.84.1.el6' '2.6.32-431.85.1.el6'
	 '2.6.32-431.85.2.el6' '2.6.32-431.86.1.el6' '2.6.32-431.87.1.el6' '2.6.32-431.89.2.el6' '2.6.32-431.89.4.el6'
	 '2.6.32-431.90.1.el6' '2.6.32-431.91.3.el6' '2.6.32-431.93.2.el6' '2.6.32-431.94.1.el6' '2.6.32-431.94.2.el6'
	 '2.6.32-504.el6' '2.6.32-504.1.3.el6' '2.6.32-504.3.3.el6' '2.6.32-504.8.1.el6' '2.6.32-504.8.2.bgq.el6'
	 '2.6.32-504.12.2.el6' '2.6.32-504.16.2.el6' '2.6.32-504.23.4.el6' '2.6.32-504.30.3.el6' '2.6.32-504.30.5.p7ih.el6'
	 '2.6.32-504.30.6.p7ih.el6' '2.6.32-504.33.2.el6' '2.6.32-504.36.1.el6' '2.6.32-504.38.1.el6' '2.6.32-504.40.1.el6'
	 '2.6.32-504.43.1.el6' '2.6.32-504.46.1.el6' '2.6.32-504.49.1.el6' '2.6.32-504.50.1.el6' '2.6.32-504.51.1.el6'
	 '2.6.32-504.52.1.el6' '2.6.32-504.54.1.el6' '2.6.32-504.55.1.el6' '2.6.32-504.56.1.el6' '2.6.32-504.57.1.el6'
	 '2.6.32-504.58.1.el6' '2.6.32-504.60.2.el6' '2.6.32-504.60.3.el6' '2.6.32-504.62.1.el6' '2.6.32-504.63.2.el6'
	 '2.6.32-504.63.3.el6' '2.6.32-504.64.1.el6' '2.6.32-504.64.4.el6' '2.6.32-504.65.1.el6' '2.6.32-504.66.1.el6'
	 '2.6.32-504.68.2.el6' '2.6.32-504.69.3.el6' '2.6.32-504.71.1.el6' '2.6.32-504.72.1.el6' '2.6.32-504.72.4.el6'
	 '2.6.32-504.76.2.el6' '2.6.32-504.78.1.el6' '2.6.32-504.78.2.el6' '2.6.32-572.el6' '2.6.32-573.el6'
	 '2.6.32-573.1.1.el6' '2.6.32-573.3.1.el6' '2.6.32-573.4.2.bgq.el6' '2.6.32-573.7.1.el6' '2.6.32-573.8.1.el6'
	 '2.6.32-573.12.1.el6' '2.6.32-573.18.1.el6' '2.6.32-573.22.1.el6' '2.6.32-573.26.1.el6' '2.6.32-573.30.1.el6'
	 '2.6.32-573.32.1.el6' '2.6.32-573.34.1.el6' '2.6.32-573.35.1.el6' '2.6.32-573.35.2.el6' '2.6.32-573.37.1.el6'
	 '2.6.32-573.38.1.el6' '2.6.32-573.40.1.el6' '2.6.32-573.41.1.el6' '2.6.32-573.42.1.el6' '2.6.32-573.42.2.el6'
	 '2.6.32-573.43.2.el6' '2.6.32-573.43.3.el6' '2.6.32-573.45.1.el6' '2.6.32-573.45.2.el6' '2.6.32-573.47.1.el6'
	 '2.6.32-573.48.1.el6' '2.6.32-573.49.1.el6' '2.6.32-573.49.3.el6' '2.6.32-573.51.1.el6' '2.6.32-573.53.1.el6'
	 '2.6.32-573.55.2.el6' '2.6.32-573.55.4.el6' '2.6.32-573.59.1.el6' '2.6.32-573.60.1.el6' '2.6.32-573.60.4.el6'
	 '2.6.32-573.62.1.el6' '2.6.32-573.65.2.el6' '2.6.32-642.el6' '2.6.32-642.1.1.el6' '2.6.32-642.3.1.el6'
	 '2.6.32-642.4.2.el6' '2.6.32-642.6.1.el6' '2.6.32-642.6.2.el6' '2.6.32-642.11.1.el6' '2.6.32-642.13.1.el6'
	 '2.6.32-642.13.2.el6' '2.6.32-642.15.1.el6' '2.6.32-682.el6' '2.6.32-683.el6' '2.6.32-696.el6'
	 '2.6.32-696.1.1.bgq.el6' '2.6.32-696.1.1.el6' '2.6.32-696.3.1.el6' '2.6.32-696.3.2.el6' '2.6.32-696.6.3.el6'
	 '2.6.32-696.10.1.el6' '2.6.32-696.10.2.el6' '2.6.32-696.10.3.el6' '2.6.32-696.13.2.el6' '2.6.32-696.16.1.el6'
	 '2.6.32-696.18.7.el6' '2.6.32-696.20.1.el6' '2.6.32-696.23.1.el6' '2.6.32-696.28.1.el6' '2.6.32-696.30.1.el6'
	 '2.6.32-749.el6' '2.6.32-751.el6' '2.6.32-752.el6' '2.6.32-754.el6' '2.6.32-754.2.1.el6'
	 '2.6.32-754.3.5.el6' '2.6.32-754.6.3.el6' '2.6.32-754.9.1.el6' '2.6.32-754.10.1.el6' '2.6.32-754.11.1.el6'
	 '2.6.32-754.12.1.el6' '2.6.32-754.14.2.el6' '3.10.0-121.el7' '3.10.0-123.el7' '3.10.0-123.1.2.el7'
	 '3.10.0-123.4.2.el7' '3.10.0-123.4.4.el7' '3.10.0-123.6.3.el7' '3.10.0-123.8.1.el7' '3.10.0-123.9.2.el7'
	 '3.10.0-123.9.3.el7' '3.10.0-123.13.1.el7' '3.10.0-123.13.2.el7' '3.10.0-123.20.1.el7' '3.10.0-229.ael7b'
	 '3.10.0-229.el7' '3.10.0-229.1.2.ael7b' '3.10.0-229.1.2.el7' '3.10.0-229.4.2.ael7b' '3.10.0-229.4.2.el7'
	 '3.10.0-229.7.2.ael7b' '3.10.0-229.7.2.el7' '3.10.0-229.11.1.ael7b' '3.10.0-229.11.1.el7' '3.10.0-229.14.1.ael7b'
	 '3.10.0-229.14.1.el7' '3.10.0-229.20.1.ael7b' '3.10.0-229.20.1.el7' '3.10.0-229.24.2.ael7b' '3.10.0-229.24.2.el7'
	 '3.10.0-229.26.2.ael7b' '3.10.0-229.26.2.el7' '3.10.0-229.28.1.ael7b' '3.10.0-229.28.1.el7' '3.10.0-229.30.1.ael7b'
	 '3.10.0-229.30.1.el7' '3.10.0-229.34.1.ael7b' '3.10.0-229.34.1.el7' '3.10.0-229.38.1.ael7b' '3.10.0-229.38.1.el7'
	 '3.10.0-229.40.1.ael7b' '3.10.0-229.40.1.el7' '3.10.0-229.42.1.ael7b' '3.10.0-229.42.1.el7' '3.10.0-229.42.2.ael7b'
	 '3.10.0-229.42.2.el7' '3.10.0-229.44.1.ael7b' '3.10.0-229.44.1.el7' '3.10.0-229.46.1.ael7b' '3.10.0-229.46.1.el7'
	 '3.10.0-229.48.1.ael7b' '3.10.0-229.48.1.el7' '3.10.0-229.49.1.ael7b' '3.10.0-229.49.1.el7' '3.10.0-327.el7'
	 '3.10.0-327.3.1.el7' '3.10.0-327.4.4.el7' '3.10.0-327.4.5.el7' '3.10.0-327.10.1.el7' '3.10.0-327.13.1.el7'
	 '3.10.0-327.18.2.el7' '3.10.0-327.22.2.el7' '3.10.0-327.28.2.el7' '3.10.0-327.28.3.el7' '3.10.0-327.36.1.el7'
	 '3.10.0-327.36.2.el7' '3.10.0-327.36.3.el7' '3.10.0-327.41.3.el7' '3.10.0-327.41.4.el7' '3.10.0-327.44.2.el7'
	 '3.10.0-327.46.1.el7' '3.10.0-327.49.2.el7' '3.10.0-327.53.1.el7' '3.10.0-327.55.1.el7' '3.10.0-327.55.2.el7'
	 '3.10.0-327.55.3.el7' '3.10.0-327.58.1.el7' '3.10.0-327.59.1.el7' '3.10.0-327.59.2.el7' '3.10.0-327.59.3.el7'
	 '3.10.0-327.61.3.el7' '3.10.0-327.62.1.el7' '3.10.0-327.62.4.el7' '3.10.0-327.64.1.el7' '3.10.0-327.66.1.el7'
	 '3.10.0-327.66.3.el7' '3.10.0-327.66.5.el7' '3.10.0-327.70.1.el7' '3.10.0-327.71.1.el7' '3.10.0-327.71.4.el7'
	 '3.10.0-327.73.1.el7' '3.10.0-327.76.1.el7' '3.10.0-327.77.1.el7' '3.10.0-327.78.2.el7' '3.10.0-514.el7'
	 '3.10.0-514.2.2.el7' '3.10.0-514.6.1.el7' '3.10.0-514.6.2.el7' '3.10.0-514.10.2.el7' '3.10.0-514.16.1.el7'
	 '3.10.0-514.16.2.p7ih.el7' '3.10.0-514.21.1.el7' '3.10.0-514.21.2.el7' '3.10.0-514.26.1.el7' '3.10.0-514.26.2.el7'
	 '3.10.0-514.28.1.el7' '3.10.0-514.28.2.el7' '3.10.0-514.32.2.el7' '3.10.0-514.32.3.el7' '3.10.0-514.35.1.el7'
	 '3.10.0-514.36.1.el7' '3.10.0-514.36.5.el7' '3.10.0-514.41.1.el7' '3.10.0-514.44.1.el7' '3.10.0-514.48.1.el7'
	 '3.10.0-514.48.3.el7' '3.10.0-514.48.5.el7' '3.10.0-514.51.1.el7' '3.10.0-514.53.1.el7' '3.10.0-514.55.4.el7'
	 '3.10.0-514.58.1.el7' '3.10.0-514.61.1.el7' '3.10.0-514.62.1.el7' '3.10.0-514.63.1.el7' '3.10.0-514.64.2.el7'
	 '3.10.0-693.el7' '3.10.0-693.1.1.el7' '3.10.0-693.2.1.el7' '3.10.0-693.2.2.el7' '3.10.0-693.5.2.el7'
	 '3.10.0-693.5.2.p7ih.el7' '3.10.0-693.11.1.el7' '3.10.0-693.11.6.el7' '3.10.0-693.17.1.el7' '3.10.0-693.21.1.el7'
	 '3.10.0-693.25.2.el7' '3.10.0-693.25.4.el7' '3.10.0-693.25.7.el7' '3.10.0-693.33.1.el7' '3.10.0-693.35.1.el7'
	 '3.10.0-693.37.4.el7' '3.10.0-693.39.1.el7' '3.10.0-693.43.1.el7' '3.10.0-693.44.1.el7' '3.10.0-693.46.1.el7'
	 '3.10.0-693.47.2.el7' '3.10.0-861.el7' '3.10.0-862.el7' '3.10.0-862.2.3.el7' '3.10.0-862.3.2.el7'
	 '3.10.0-862.3.3.el7' '3.10.0-862.6.3.el7' '3.10.0-862.9.1.el7' '3.10.0-862.11.6.el7' '3.10.0-862.14.4.el7'
	 '3.10.0-862.20.2.el7' '3.10.0-862.25.3.el7' '3.10.0-862.27.1.el7' '3.10.0-862.29.1.el7' '3.10.0-862.32.1.el7'
	 '3.10.0-862.32.2.el7' '3.10.0-862.34.1.el7' '3.10.0-957.el7' '3.10.0-957.1.3.el7' '3.10.0-957.5.1.el7'
	 '3.10.0-957.10.1.el7' '3.10.0-957.12.1.el7' '3.10.0-957.12.2.el7' '3.10.0-957.21.2.el7' '3.10.0-1049.el7'
	 '4.11.0-44.el7a' '4.11.0-44.2.1.el7a' '4.11.0-44.4.1.el7a' '4.11.0-44.6.1.el7a' '4.11.0-44.7.1.el7a'
	 '4.14.0-49.el7a' '4.14.0-49.2.2.el7a' '4.14.0-49.8.1.el7a' '4.14.0-49.10.1.el7a' '4.14.0-49.13.1.el7a'
	 '4.14.0-104.el7a' '4.14.0-115.el7a' '4.14.0-115.2.2.el7a' '4.14.0-115.5.1.el7a' '4.14.0-115.6.1.el7a'
	 '4.14.0-115.7.1.el7a' '4.14.0-115.8.1.el7a' '4.18.0-80.el8' '4.18.0-80.1.2.el8_0' '2.6.33.9-rt31.66.el6rt'
	 '2.6.33.9-rt31.74.el6rt' '2.6.33.9-rt31.75.el6rt' '2.6.33.9-rt31.79.el6rt' '3.0.9-rt26.45.el6rt' '3.0.9-rt26.46.el6rt'
	 '3.0.18-rt34.53.el6rt' '3.0.25-rt44.57.el6rt' '3.0.30-rt50.62.el6rt' '3.0.36-rt57.66.el6rt' '3.2.23-rt37.56.el6rt'
	 '3.2.33-rt50.66.el6rt' '3.6.11-rt28.20.el6rt' '3.6.11-rt30.25.el6rt' '3.6.11.2-rt33.39.el6rt' '3.6.11.5-rt37.55.el6rt'
	 '3.8.13-rt14.20.el6rt' '3.8.13-rt14.25.el6rt' '3.8.13-rt27.33.el6rt' '3.8.13-rt27.34.el6rt' '3.8.13-rt27.40.el6rt'
	 '3.10.0-229.rt56.141.el7' '3.10.0-229.1.2.rt56.141.2.el7_1' '3.10.0-229.4.2.rt56.141.6.el7_1' '3.10.0-229.7.2.rt56.141.6.el7_1' '3.10.0-229.11.1.rt56.141.11.el7_1'
	 '3.10.0-229.14.1.rt56.141.13.el7_1' '3.10.0-229.20.1.rt56.141.14.el7_1' '3.10.0-327.rt56.204.el7' '3.10.0-327.4.5.rt56.206.el7_2' '3.10.0-327.10.1.rt56.211.el7_2'
	 '3.10.0-327.13.1.rt56.216.el7_2' '3.10.0-327.18.2.rt56.223.el7_2' '3.10.0-327.22.2.rt56.230.el7_2' '3.10.0-327.28.2.rt56.234.el7_2' '3.10.0-327.28.3.rt56.235.el7'
	 '3.10.0-327.36.1.rt56.237.el7' '3.10.0-327.36.3.rt56.238.el7' '3.10.0-514.rt56.420.el7' '3.10.0-514.2.2.rt56.424.el7' '3.10.0-514.6.1.rt56.429.el7'
	 '3.10.0-514.6.1.rt56.430.el7' '3.10.0-514.10.2.rt56.435.el7' '3.10.0-514.16.1.rt56.437.el7' '3.10.0-514.21.1.rt56.438.el7' '3.10.0-514.26.1.rt56.442.el7'
	 '3.10.0-693.rt56.617.el7' '3.10.0-693.2.1.rt56.620.el7' '3.10.0-693.2.2.rt56.623.el7' '3.10.0-693.5.2.rt56.626.el7' '3.10.0-693.11.1.rt56.632.el7'
	 '3.10.0-693.11.1.rt56.639.el7' '3.10.0-693.17.1.rt56.636.el7' '3.10.0-693.21.1.rt56.639.el7' '3.10.0-861.rt56.803.el7' '3.10.0-862.rt56.804.el7'
	 '3.10.0-862.2.3.rt56.806.el7' '3.10.0-862.3.2.rt56.808.el7' '3.10.0-862.3.3.rt56.809.el7' '3.10.0-862.6.3.rt56.811.el7' '3.10.0-862.11.6.rt56.819.el7'
	 '3.10.0-862.14.4.rt56.821.el7' '3.10.0-957.rt56.910.el7' '3.10.0-957.1.3.rt56.913.el7' '3.10.0-957.5.1.rt56.916.el7' '3.10.0-957.10.1.rt56.921.el7'
	 '3.10.0-957.12.1.rt56.927.el7' '3.10.0-957.12.2.rt56.929.el7' '3.10.0-957.21.2.rt56.934.el7' '3.10.0-1048.rt56.1008.el7' '3.10.33-rt32.33.el6rt'
	 '3.10.33-rt32.34.el6rt' '3.10.33-rt32.43.el6rt' '3.10.33-rt32.45.el6rt' '3.10.33-rt32.51.el6rt' '3.10.33-rt32.52.el6rt'
	 '3.10.58-rt62.58.el6rt' '3.10.58-rt62.60.el6rt' '4.18.0-80.rt9.138.el8' '4.18.0-80.1.2.rt9.145.el8_0' '3.10.0-229.rt56.144.el6rt'
	 '3.10.0-229.rt56.147.el6rt' '3.10.0-229.rt56.149.el6rt' '3.10.0-229.rt56.151.el6rt' '3.10.0-229.rt56.153.el6rt' '3.10.0-229.rt56.158.el6rt'
	 '3.10.0-229.rt56.161.el6rt' '3.10.0-229.rt56.162.el6rt' '3.10.0-327.rt56.170.el6rt' '3.10.0-327.rt56.171.el6rt' '3.10.0-327.rt56.176.el6rt'
	 '3.10.0-327.rt56.183.el6rt' '3.10.0-327.rt56.190.el6rt' '3.10.0-327.rt56.194.el6rt' '3.10.0-327.rt56.195.el6rt' '3.10.0-327.rt56.197.el6rt'
	 '3.10.0-327.rt56.198.el6rt' '3.10.0-327.rt56.199.el6rt' '3.10.0-514.rt56.210.el6rt' '3.10.0-514.rt56.215.el6rt' '3.10.0-514.rt56.219.el6rt'
	 '3.10.0-514.rt56.221.el6rt' '3.10.0-514.rt56.228.el6rt' '3.10.0-514.rt56.231.el6rt' '3.10.0-693.2.1.rt56.585.el6rt' '3.10.0-693.2.2.rt56.588.el6rt'
	 '3.10.0-693.5.2.rt56.592.el6rt' '3.10.0-693.11.1.rt56.597.el6rt' '3.10.0-693.11.1.rt56.606.el6rt' '3.10.0-693.17.1.rt56.604.el6rt' '3.10.0-693.21.1.rt56.607.el6rt'
	 '3.10.0-693.25.2.rt56.612.el6rt' '3.10.0-693.25.4.rt56.613.el6rt' '3.10.0-693.25.7.rt56.615.el6rt' '3.10.0-693.33.1.rt56.621.el6rt' '3.10.0-693.35.1.rt56.625.el6rt'
	 '3.10.0-693.37.4.rt56.629.el6rt' '3.10.0-693.39.1.rt56.629.el6rt' '3.10.0-693.43.1.rt56.630.el6rt' '3.10.0-693.44.1.rt56.633.el6rt' '3.10.0-693.46.1.rt56.639.el6rt'
	 '3.10.0-693.47.2.rt56.641.el6rt'
)

KPATCH_MODULE_NAMES=()


basic_args() {
    # Parses basic commandline arguments and sets basic environment.
    #
    # Args:
    #     parameters - an array of commandline arguments
    #
    # Side effects:
    #     Exits if --help parameters is used
    #     Sets COLOR constants and debug variable

    local parameters=( "$@" )

    RED="\\033[1;31m"
    YELLOW="\\033[1;33m"
    GREEN="\\033[1;32m"
    BOLD="\\033[1m"
    RESET="\\033[0m"
    for parameter in "${parameters[@]}"; do
        if [[ "$parameter" == "-h" || "$parameter" == "--help" ]]; then
            echo "Usage: $( basename "$0" ) [-n | --no-colors] [-d | --debug]"
            exit 1
        elif [[ "$parameter" == "-n" || "$parameter" == "--no-colors" ]]; then
            RED=""
            YELLOW=""
            GREEN=""
            BOLD=""
            RESET=""
        elif [[ "$parameter" == "-d" || "$parameter" == "--debug" ]]; then
            debug=true
        fi
    done
}


basic_reqs() {
    # Prints common disclaimer and checks basic requirements.
    #
    # Args:
    #     CVE - string printed in the disclaimer
    #
    # Side effects:
    #     Exits when 'rpm' command is not available

    local CVE="$1"

    # Disclaimer
    echo
    echo -e "${BOLD}This script (v$VERSION) is primarily designed to detect $CVE on supported"
    echo -e "Red Hat Enterprise Linux systems and kernel packages."
    echo -e "Result may be inaccurate for other RPM based systems.${RESET}"
    echo

    # RPM is required
    if ! command -v rpm &> /dev/null; then
        echo "'rpm' command is required, but not installed. Exiting."
        exit 1
    fi
}


require_root() {
    # Checks if user is root.
    #
    # Side effects:
    #     Exits when user is not root.
    #
    # Notes:
    #     MOCK_EUID can be used to mock EUID variable

    local euid=${MOCK_EUID:-$EUID}

    # Am I root?
    if (( euid != 0 )); then
        echo "This script must run with elevated privileges (e.g. as root)"
        exit 1
    fi
}


check_supported_kernel() {
    # Checks if running kernel is supported.
    #
    # Args:
    #     running_kernel - kernel string as returned by 'uname -r'
    #
    # Side effects:
    #     Exits when running kernel is obviously not supported

    local running_kernel="$1"

    # Check supported platform
    if [[ "$running_kernel" != *".el"[5-8]* ]]; then
        echo -e "${RED}This script is meant to be used only on RHEL 5-8.${RESET}"
        exit 1
    fi
}


get_rhel() {
    # Gets RHEL number.
    #
    # Args:
    #     running_kernel - kernel string as returned by 'uname -r'
    #
    # Prints:
    #     RHEL number, e.g. '5', '6', '7', or '8'

    local running_kernel="$1"

    local rhel
    rhel=$( sed -r -n 's/^.*el([[:digit:]]).*$/\1/p' <<< "$running_kernel" )
    echo "$rhel"
}


set_default_values() {
    vulnerable=1
    result=2
    iptables_rule=0
    firewalld_rule=0
    ipt_v4_old=1
    ipt_v4_syn=1
    ipt_v6_old=1
    ipt_v6_syn=1
    fwd_v4_old=1
    fwd_v4_syn=1
    fwd_v6_old=1
    fwd_v6_syn=1
    mitigation_kpatch=0
    mitigation_sysctl=0
    mitigation_iptables=0
    system_state="${RED}Vulnerable${RESET}"
}


check_kernel() {
    # Checks kernel if it is in list of vulnerable kernels.
    #
    # Args:
    #     running_kernel - kernel string as returned by 'uname -r'
    #     vulnerable_versions - an array of vulnerable versions
    #
    # Prints:
    #     Vulnerable kernel string as returned by 'uname -r', or nothing

    local running_kernel="$1"
    shift
    local vulnerable_versions=( "$@" )

    for tested_kernel in "${vulnerable_versions[@]}"; do
        if [[ "$running_kernel" == *"$tested_kernel"* ]]; then
            echo "$running_kernel"
            break
        fi
    done
}


check_kpatch() {
    # Checks if specific kpatch listed in a kpatch list is applied.
    #
    # Args:
    #     kpatch_module_names - an array of kpatches
    #
    # Prints:
    #     Found kpatch, or nothing

    local kpatch_module_names=( "$@" )

    # Get loaded kernel modules
    local modules=$( lsmod )

    # Check if kpatch is installed
    for tested_kpatch in "${kpatch_module_names[@]}"; do
        if [[ "$modules" == *"$tested_kpatch"* ]]; then
            echo "$tested_kpatch"
            break
        fi
    done
}


parse_facts() {
    # Gathers all available information and stores it in global variables. Only store facts and
    # do not draw conclusion in this function for better maintainability.
    #
    # Side effects:
    #     Sets many global boolean flags and content variables
    vulnerable_kernel=$( check_kernel "$running_kernel" "${VULNERABLE_KERNELS[@]}" )

    # Check whether a mitigating kpatch is applied
    if [[ -n ${MOCK_KPATCH} ]]; then
        KPATCH_MODULE_NAMES=(${KPATCH_MODULE_NAMES[@]} ${MOCK_KPATCH})
    fi

    kpatch_fix=$( check_kpatch "${KPATCH_MODULE_NAMES[@]}" )

    # Check whether SACK is enabled in sysctl
    sack_sysctl=$(sysctl -n net.ipv4.tcp_sack)

    # Check whether iptables drops low MSS connections
    # Check both iptables and firewalld
    iptables -C INPUT -p tcp -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    ipt_v4_old=$?
    ip6tables -C INPUT -p tcp -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    ipt_v6_old=$?

    iptables -C INPUT -p tcp -m tcp --tcp-flags SYN SYN -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    ipt_v4_syn=$?
    ip6tables -C INPUT -p tcp -m tcp --tcp-flags SYN SYN -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    ipt_v6_syn=$?

    firewall-cmd -q --permanent --direct --query-rule ipv4 filter INPUT 0 -p tcp -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    fwd_v4_old=$?
    firewall-cmd -q --permanent --direct --query-rule ipv6 filter INPUT 0 -p tcp -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    fwd_v6_old=$?
    firewall-cmd -q --permanent --direct --query-rule ipv4 filter INPUT 0 -p tcp --tcp-flags SYN SYN -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    fwd_v4_syn=$?
    firewall-cmd -q --permanent --direct --query-rule ipv6 filter INPUT 0 -p tcp --tcp-flags SYN SYN -m tcpmss --mss 1:500 -j DROP 2> /dev/null
    fwd_v6_syn=$?

}


draw_conclusions() {
    # Draws conclusions based on available system data.
    #
    # Side effects:
    #     Sets many global boolean flags and content variables
    if [[ -z ${vulnerable_kernel} ]]; then
        vulnerable=0
        result=0
        system_state="${GREEN}Not affected${RESET}"
    else
        if [[ -n ${kpatch_fix} ]]; then
            mitigation_kpatch=1
        fi

        if (( sack_sysctl == 0 )); then
            mitigation_sysctl=1
        fi

        if (( (( ipt_v4_old == 0 || ipt_v4_syn == 0 )) &&
              (( ipt_v6_old == 0 || ipt_v6_syn == 0 )) )); then
            iptables_rule=1
        fi

        if (( (( fwd_v4_old == 0 || fwd_v4_syn == 0 )) &&
              (( fwd_v6_old == 0 || fwd_v6_syn == 0 )) )); then
            firewalld_rule=1
        fi

        if (( iptables_rule || firewalld_rule )); then
            mitigation_iptables=1
        fi

        if (( mitigation_kpatch || mitigation_sysctl || mitigation_iptables )); then
            result=0
            system_state="${YELLOW}Mitigated${RESET}"
        fi
    fi
}


debug_print() {
    # Prints selected variables when debugging is enabled.

    variables=( running_kernel rhel vulnerable_kernel kpatch_fix sack_sysctl
                ipt_v4_old ipt_v4_syn ipt_v6_old ipt_v6_syn fwd_v4_old
                fwd_v4_syn fwd_v6_old fwd_v6_syn iptables_rule firewalld_rule
                mitigation_kpatch mitigation_systcl mitigation_iptables )
    for variable in "${variables[@]}"; do
        echo "$variable = *${!variable}*"
    done
    echo
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    basic_args "$@"
    basic_reqs "CVE-2019-11477"
    running_kernel=$( uname -r )
    check_supported_kernel "$running_kernel"
    require_root

    rhel=$( get_rhel "$running_kernel" )
    if (( rhel == 5 )); then
        export PATH="/sbin:/usr/sbin:$PATH"
    fi

    set_default_values
    parse_facts
    draw_conclusions

    # Debug prints
    if [[ "$debug" ]]; then
        debug_print
    fi

    # Results
    echo -e "Running kernel: ${running_kernel}"
    echo -e
    echo -e "This system is ${system_state}"
    echo -e
    if (( vulnerable )); then
        if (( mitigation_kpatch || mitigation_sysctl || mitigation_iptables )); then
            echo -e "${YELLOW}* Running kernel is vulnerable${RESET}"
            if (( mitigation_kpatch )); then
                echo -e "${GREEN}* kpatch fix is applied${RESET}"
            fi
            if (( mitigation_sysctl )); then
                echo -e "${GREEN}* sysctl mitigation is applied${RESET}"
            fi
            if (( mitigation_iptables)); then
                echo -e "${GREEN}* iptables mitigation is applied${RESET}"
            fi
        else
            echo -e "${RED}* Running kernel is vulnerable${RESET}"
        fi
    fi
    echo -e
    echo -e "For more information about this vulnerability, see:"
    echo -e "${ARTICLE}"
    exit "$result"
fi




