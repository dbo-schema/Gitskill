#!/bin/bash
#backup config file
mkdir -p /root/backup
cp /etc/shadow /root/backup
cp /etc/passwd /root/backup
cp /etc/pam.d/sshd /root/backup
cp /etc/login.defs /root/backup
cp /etc/pam.d/system-auth /root/backup
cp /etc/pam.d/su /root/backup
cp /etc/pam.d/login /root/backup
cp /etc/snmp/snmpd.conf /root/backup
cp /etc/ssh/sshd_config /root/backup
cp /etc/vsftpd/vsftpd.conf /root/backup
cp /etc/profile /root/backup
cp /etc/syslog.conf /root/backup
cp /etc/csh.cshrc /root/backup
cp /etc/bashrc /root/backup
cp /etc/aliases  /root/backup

echo -e "\033[32m1.1 检查空口令账户 \033[0m"
pass=`awk -F: '($2 == "") { print $1 }' /etc/shadow`
if [ "${pass}" == "" ];then
	echo "无空口令账户"
else
	echo "空口令账户为：$pass"
fi
echo "                             "

echo -e "\033[32m1.2 禁用无用账号 \033[0m"
echo "可登录系统账号如下："
cat /etc/passwd |grep -v nologin
echo "使用usermod -s /usr/sbin/nologin <用户名>来禁用无用账户"

echo "                             "
echo -e "\033[32m1.3 账号锁定策略 \033[0m"
policyStr='auth required pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=100'
userpolicy=`cat /etc/pam.d/sshd |egrep "auth\s+required\s+pam_tally2.so"`
tally='account  required   pam_tally2.so'
if [ "${userpolicy}" == "" ];then
	sed -i -re "/auth\s+required\s+pam_sepermit.so/i$policyStr" /etc/pam.d/sshd
#	sed -i "1a${policyStr}" /etc/pam.d/sshd
else
	sed -i "s@${userpolicy}@${policyStr}@" /etc/pam.d/sshd
fi
sed -i -re "/account\s+required/a$tally" /etc/pam.d/sshd
cat /etc/pam.d/sshd |grep pam_tally2.so

echo "                             "
echo -e "\033[32m1.4 检查特殊账号 \033[0m"
echo "UID为零的账号的账号："
awk -F: '($3==0)' /etc/passwd

echo "                             "
echo -e "\033[32m1.5 检查口令周期策略 \033[0m"
pass_mas_day="PASS_MAX_DAYS   90"
pass_min_day="PASS_MIN_DAYS   2"
pass_min_len="PASS_MIN_LEN   8"
pass_warn_age="PASS_WARN_AGE   32"
sed -i "s/^PASS_MAX_DAYS.*/${pass_mas_day}/" /etc/login.defs
sed -i "s/^PASS_MIN_DAYS.*/${pass_min_day}/" /etc/login.defs
sed -i "s/^PASS_MIN_LEN.*/${pass_min_len}/" /etc/login.defs
sed -i "s/^PASS_WARN_AGE.*/${pass_warn_age}/" /etc/login.defs
cat /etc/login.defs | grep PASS

echo "                             "
echo -e "\033[32m1.6 检查口令复杂度策略 \033[0m"
pass_policy="password requisite pam_cracklib.so minlen=8 lcredit=-1 dcredit=-1 ocredit=-1"
passcheck=`cat /etc/pam.d/system-auth |grep pam_cracklib.so | grep -v try_first_pass`
if [ "${passcheck}" == "" ];then
	sed -i -re "/password\s+requisite/i$pass_policy" /etc/pam.d/system-auth
#	sed -i "1i${pass_policy}" /etc/pam.d/system-auth
else
	sed -i "s/\${passcheck}/\${pass_policy}/" /etc/pam.d/system-auth
fi

auth111='auth  required  pam_tally2.so deny=5 unlock_time=300'
account111='account  required   pam_tally2.so'
authcheck=`egrep "auth\s+required\s+pam_tally2.so\s+deny=5\s+unlock_time=300" /etc/pam.d/system-auth`
accountcheck=`egrep "account\s+required\s+pam_tally2.so" /etc/pam.d/system-auth`
if [ "$authcheck" == "" ];then
	sed -i -re "/auth\s+required\s+pam_env.so/a$auth111" /etc/pam.d/system-auth
else
	sed -i "s/$authcheck/$auth111/" /etc/pam.d/system-auth
fi
if [ "$accountcheck" == "" ];then
	sed -i -re "/account\s+required\s+pam_unix.so/a$account111" /etc/pam.d/system-auth
else
	sed -i "s/$accountcheck/$account111/" /etc/pam.d/system-auth
fi
#sed -i "1i${auth111}" /etc/pam.d/system-auth
#sed -i "1i${account111}" /etc/pam.d/system-auth
cat /etc/pam.d/system-auth |grep pam_cracklib.so
cat /etc/pam.d/system-auth |grep pam_tally2

echo "                             "
echo -e "\033[32m1.7 查看SNMP团体字 \033[0m"
cat /etc/snmp/snmpd.conf |grep com2sec

echo "                             "
echo -e "\033[32m3.1 检查SSH服务 \033[0m"
ssh_policy="PermitRootLogin no"
protocol_policy="Protocol 2"
MaxAuthTries_policy="MaxAuthTries 3"
ssh_check=`cat /etc/ssh/sshd_config | grep PermitRootLogin | grep -v without-password`
MaxAuthTries=`cat /etc/ssh/sshd_config | grep MaxAuthTries`
protocol_check=`cat /etc/ssh/sshd_config | grep Protocol`
sed -i "s@${ssh_check}@${ssh_policy}@g" /etc/ssh/sshd_config
if [ "${protocol_check}" == "" ];then
	sed -i "/${ssh_policy}/a ${protocol_policy}" /etc/ssh/sshd_config
fi
sed -i "s@${MaxAuthTries}@${MaxAuthTries_policy}@" /etc/ssh/sshd_config
service sshd reload

echo "                             "
echo -e "\033[32m3.2 检查.rhosts和/etc/hosts.equiv文件 \033[0m"
echo ".rhosts文件:"
cat /etc/hosts.equiv

echo "                             "
echo -e "\033[32m4.1 重要目录和文件的权限设置 \033[0m"
chmod 644 /etc/passwd
chmod 600 /etc/shadow

echo "                             "
echo -e "\033[32m4.2 设置umask值 \033[0m"
sed -i -re 's/umask [0-9].*/umask 077/g' /etc/profile
sed -i -re 's/umask [0-9].*/umask 077/g' /etc/csh.cshrc
sed -i -re 's/umask [0-9].*/umask 077/g' /etc/bashrc
cat /etc/profile |grep umask |grep -v default
cat /etc/csh.cshrc |grep umask |grep -v default
cat /etc/bashrc |grep umask |grep -v default

echo "                             "
echo -e "\033[32m4.3 设置Bash保留历史命令的条数 \033[0m"
histsize=`cat /etc/profile|grep HISTSIZE=`
histfilesize=`cat /etc/profile|grep HISTFILESIZE=`
histsizepolicy="HISTSIZE=5"
histfilesizepolicy="HISTFILESIZE=5"
if [ "${histsize}" == "" ];then
	sed -i '$a HISTSIZE=5' /etc/profile
else
	sed -i "s/${histsize}/${histsizepolicy}/" /etc/profile
fi
if [ "${histfilesize}" == "" ];then
        sed -i '$a HISTFILESIZE=5' /etc/profile
else
        sed -i "s/${histfilesize}/${histfilesizepolicy}/" /etc/profile
fi
cat /etc/profile|grep HISTSIZE=
cat /etc/profile|grep HISTFILESIZE=

echo "                             "
echo -e "\033[32m4.4 设置登录超时 \033[0m"
tmout_check=`cat /etc/profile | grep TMOUT|grep -v export`
tmout_set="TMOUT=180"
if [ "${tmout_check}" == "" ];then
	sed -i '$a TMOUT=180' /etc/profile 
else
	sed -i "s@${tmout_check}@${tmout_set}@" /etc/profile
fi
cat /etc/profile | grep TMOUT

echo "                             "
echo -e "\033[32m5 日志设置 \033[0m"
cat /etc/rsyslog.conf |grep /var/log

echo "                             "
echo -e "\033[32mOPENSHH 版本 \033[0m"
ssh -V

echo "                             "
echo -e "\033[32mKernel 版本 \033[0m"
uname -r

echo "                             "
echo -e "\033[32m防病毒信息 \033[0m"
lsof -i:4118

echo "                             "
echo -e "\033[32m369身份鉴别 \033[0m"
sed -i "/pam_securetty.so/d" /etc/pam.d/login
sed -i "1aauth required pam_securetty.so" /etc/pam.d/login
cat /etc/pam.d/login | grep pam_securetty.so

echo "                             "
echo -e "\033[32m350身份鉴别 \033[0m"
pamunix1=`egrep "password\s+sufficient\s+pam_unix.so" /etc/pam.d/system-auth`
pamunix2="password sufficient pam_unix.so md5 shadow nullok try_first_pass use_authtok remember=5"
sed -i "s@$pamunix1@$pamunix2@" /etc/pam.d/system-auth
cat /etc/pam.d/system-auth | grep md5

echo "                             "
echo -e "\033[32m371访问控制 \033[0m"
chmod 750 /etc/rc3.d
chmod 750 /etc/rc6.d
chmod 750 /etc/rc5.d/
chmod 750 /etc/rc1.d/
chmod 600 /etc/security
chmod 750 /etc/rc4.d
chmod 644 /etc/passwd
chmod 750 /etc/rc0.d/
chmod 644 /etc/group
chmod 750 /etc/rc2.d/
chmod 644 /etc/services
chmod 600 /etc/xinetd.conf
chmod 600 /etc/grub.conf
chmod 750 /etc/init.d/
chmod 600 /etc/shadow

echo "                             "
echo -e "\033[32m389访问控制 \033[0m"
games=`egrep "games:\s+root" /etc/aliases`
ingres=`egrep "ingres:\s+root" /etc/aliases`
system=`egrep "system:\s+root" /etc/aliases`
toor=`egrep "toor:\s+root" /etc/aliases`
manager=`egrep "manager:\s+root" /etc/aliases`
dumper=`egrep "dumper:\s+root" /etc/aliases`
operator=`egrep "operator:\s+root" /etc/aliases`
decode=`egrep "decode:\s+root" /etc/aliases`
root=`egrep "root:\s+marc" /etc/aliases`
uucp=`egrep "uucp:\s+root" /etc/aliases`
sed -i "s/$games/#$games/" /etc/aliases
sed -i "s/$ingres/#$ingres/" /etc/aliases
sed -i "s/$system/#$system/" /etc/aliases
sed -i "s/$toor/#$toor/" /etc/aliases
sed -i "s/$manager/#$manager/" /etc/aliases
sed -i "s/$dumper/#$dumper/" /etc/aliases
sed -i "s/$operator/#$operator/" /etc/aliases
sed -i "s/$decode/#$decode/" /etc/aliases
sed -i "s/$root/#$root/" /etc/aliases
sed -i "s/$uucp/#$uucp/" /etc/aliases
cat /etc/aliases | grep games
cat /etc/aliases | grep ingres
cat /etc/aliases | grep system
cat /etc/aliases | grep toor
cat /etc/aliases | grep manager
cat /etc/aliases | grep dumper
cat /etc/aliases | grep operator
cat /etc/aliases | grep decode
cat /etc/aliases | grep marc
cat /etc/aliases | grep uucp