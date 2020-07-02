#!/bin/bash
# Autor: Douglas Silveira Baptista
# Script para coleta massiva
#

# Cria o diretorio archive se nao existir.
# Move coleta.log.? para archive
[ ! -d archive ] && mkdir archive
[ -f coleta.log.* ] && mv coleta.log.* archive

# Zera os arquivos de comandos e ips
echo "" > comandos.txt ; echo "" > ips.txt

#Validações SSH, data-atual
ssh_version=$(ssh -V 2>&1)
data_atual=$(date "+%Y%d%m-%H%M")
# Valida versão SSH
grep -q -o "OpenSSH_7.4p1" <<< $(ssh -V 2>&1) && echo "Versão SSH atual $ssh_version - OK" || echo "Versão SSH diferente da recomendada, favor instalar a versão OpenSSH_7.4p1"

# A fazer: expect_exist=$(find / -type f -name "expect")
# A fazer: tput_exist=$(find / -type f -name "tput")
# A fazer: [ ! -f $expect_exist ] && echo "O programa $expect_exist existe - OK" || echo "Para se conectar aos equipamentos, instale o expect"
# A fazer: [ ! -f $tput_exist ] && echo "O programa $tput existe - OK" || echo "Considere em instalar o TPUT"


#Retira valor das variáveis
#unset expect_exist
#unset tput_exist
unset ssh_version

# Decisão usuário
tput bold
while [[ ${REPLY} != [0-4] ]]
do
        echo -e "\nEscolha o equipamento\n\n"
        echo -e "1) CMTS"
        echo -e "2) Router Cisco"
        echo -e "3) Router Huawei"
        echo -e "4) OLT"
        echo -e "0) Sair\n"
        read -n 1 -p "Digite a opção desejada: "
done

case ${REPLY} in
        0)
                echo -e "\nSaindo do programa"
                ;;
        1)
                echo -e "\nAinda não está pronto\n"
                ;;
        2)
		clear
		tput setab 1
		echo -e "--------------------## Router Cisco - Comandos ##-----------------\n"
		tput setab 0
		echo -e "Insira os comandos, 1 por linha, pressione CTRL + D para terminar"
		echo -e "Não é necessário inserir terminal length 0\n"
		
		# Insere os comandos em comandos.txt
                while read -p "Insira os comandos: "
		do
			echo "${REPLY}" >> comandos.txt
                done

                # Insere os IPs em ips.txt
                tput setab 1
                echo -e "\n\n--------------------## INSERE IPS ##----------------------\n"
                tput setab 0
                while read -p "Insira os IPs: "
                do
                	sed -i -r "/^$/d" ips.txt
                	echo "${REPLY}" >> ips.txt
                	if grep -Evq '^(([0-9]{1,3}\.){3}[0-9]{1,3})$' ips.txt
			then
				echo -e "\n\nHá endereços de IP incorretos, digite todos novamente"
				echo -e "Insira os comandos, 1 por linha, pressione CTRL + D para terminar\n"
				echo "" > ips.txt
                        fi
		done


                # Remove linhas em branco de comandos.txt e ips.txt
                sed -i -r "/^$/d" comandos.txt
                sed -i -r "/^$/d" ips.txt
                # Credenciais para Login
		echo -e "\n\n--------------------## INSERE CREDENCIAIS ##--------------\n"
                read -p "Digite seu N: " user
                read -s -p "Digite sua senha: " pass
                echo -e "\n"


/usr/bin/expect << label1
log_file -a coleta.log.$data_atual

set f [open "ips.txt"]
set hosts [read \$f]
close \$f

set f [open "comandos.txt"]
set comandos [split [read \$f] "\n"]
close \$f

foreach host \$hosts {
send_user "Conectando ao host \$host\n\n"
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@\$host
expect {
timeout { send_user "Não é possivel se conectar ao IP: \$host\n\n" }
"Name or service not known" { sleep 1; send_user "\nO IP \$host está inválido\n\n" }
"Invalid key length" { send_user "\nO IP \$host contém chave menor que 1024 bits, informar o responsável\n\n" }
"*assword:" {
send "$pass\n"
expect "*#"
send "terminal length 0\n"

foreach comando \$comandos {
expect "*#"
send "\$comando\n"
sleep 3
}
expect "*#"
send "quit\n"
}
}
}
exit
label1

echo -e "\n"
echo -e "Logs coletados e salvos em $(pwd)/coleta.log.$data_atual\n"

                ;;
        3)
		clear
		tput setab 1
		echo -e "--------------------## Router Huawei - Comandos ##-----------------\n"
		tput setab 0
		echo -e "Insira os comandos, 1 por linha, pressione CTRL + D para terminar"
		echo -e "Não é necessário inserir screen-length 0 temp\n"
				
		# Insere os comandos em comandos.txt
                while read -p "Insira os comandos: "
		do
			echo "${REPLY}" >> comandos.txt
                done

                # Insere os IPs em ips.txt
                tput setab 1
                echo -e "\n\n--------------------## INSERE IPS ##----------------------\n"
                tput setab 0
                while read -p "Insira os IPs: "
               	do
                sed -i -r "/^$/d" ips.txt
                	echo "${REPLY}" >> ips.txt
                    	if grep -Evq '^(([0-9]{1,3}\.){3}[0-9]{1,3})$' ips.txt
			then
				echo -e "\n\nHá endereços de IP incorretos, digite todos novamente"
				echo -e "Insira os comandos, 1 por linha, pressione CTRL + D para terminar\n"
				echo "" > ips.txt
                        fi
		done


                 # Remove linhas em branco de comandos.txt e ips.txt
                 sed -i -r "/^$/d" comandos.txt
                 sed -i -r "/^$/d" ips.txt
                 # Credenciais para Login
		 echo -e "\n\n--------------------## INSERE CREDENCIAIS ##--------------\n"
                 read -p "Digite seu N: " user
                 read -s -p "Digite sua senha: " pass
                 echo -e "\n"
				 
/usr/bin/expect << label1
log_file -a coleta.log.$data_atual

set f [open "ips.txt"]
set hosts [read \$f]
close \$f

set f [open "comandos.txt"]
set comandos [split [read \$f] "\n"]
close \$f

foreach host \$hosts {
send_user "Conectando ao host \$host\n\n"
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@\$host
expect {
timeout { send_user "Não é possivel se conectar ao IP: \$host\n\n" }
"Name or service not known" { sleep 1; send_user "\nO IP \$host está inválido\n\n" }
"Invalid key length" { send_user "\nO IP \$host contém chave menor que 1024 bits, informar o responsável\n\n" }
"*assword:" {
send "$pass\n"
expect "*>"
send "screen-length 0 temp\n"


foreach comando \$comandos {
expect "*>"
send "\$comando\n"
sleep 3
}
expect "*>"
send "quit\n"
}
}
}
exit
label1
echo -e "\n"
echo -e "Logs coletados e salvos em $(pwd)/coleta.log.$data_atual\n"

                ;;
        4)
		clear
		tput setab 1
		echo -e "--------------------## OLT Huawei - Comandos ##-----------------\n"
		tput setab 0
		echo -e "Insira os comandos, 1 por linha, pressione CTRL + D para terminar"
		echo -e "Não é necessário enable e scroll\n"
				
		# Insere os comandos em comandos.txt
                while read -p "Insira os comandos: "
		do
			echo "${REPLY}" >> comandos.txt
                done

                # Insere os IPs em ips.txt
                tput setab 1
                echo -e "\n\n--------------------## INSERE IPS ##----------------------\n"
                tput setab 0
                while read -p "Insira os IPs: "
                do
                	sed -i -r "/^$/d" ips.txt
                    	echo "${REPLY}" >> ips.txt
                    	if grep -Evq '^(([0-9]{1,3}\.){3}[0-9]{1,3})$' ips.txt
		  	then
				echo -e "\n\nHá endereços de IP incorretos, digite todos novamente"
				echo -e "Insira os comandos, 1 por linha, pressione CTRL + D para terminar\n"
				echo "" > ips.txt
                        fi
		done


                 # Remove linhas em branco de comandos.txt e ips.txt
                 sed -i -r "/^$/d" comandos.txt
                 sed -i -r "/^$/d" ips.txt
                 # Credenciais para Login
		 echo -e "\n\n--------------------## INSERE CREDENCIAIS ##--------------\n"
                 read -p "Digite seu N: " user
                 read -s -p "Digite sua senha: " pass
                 echo -e "\n"
				 
/usr/bin/expect << label1
log_file -a coleta.log.$data_atual

set f [open "ips.txt"]
set hosts [read \$f]
close \$f

set f [open "comandos.txt"]
set comandos [split [read \$f] "\n"]
close \$f

foreach host \$hosts {
send_user "Conectando ao host \$host\n\n"
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user@\$host
expect {
timeout { send_user "Não é possivel se conectar ao IP: \$host\n\n" }
"Name or service not known" { sleep 1; send_user "\nO IP \$host está inválido\n\n" }
"*assword:" {
send "$pass\n"
expect "*>"
send "scroll\n"
expect "*>"
send "enable\n"

foreach comando \$comandos {
expect "*#"
send "\$comando\n"
sleep 3
}
expect "*#"
send "quit\n"
}
}
}
exit
label1

echo -e "\n"
echo -e "Logs coletados e salvos em $(pwd)/coleta.log.$data_atual\n"

                ;;
        *)
                echo "Opcoes invalidas"
                ;;
esac
exit

# Futuro:
# Adicionar validações de instalacao para expect / tput
# Futuro: Juniper e extreme
