#!/bin/bash
# Importando API
source ShellBot.sh

# Token do bot
bot_token='token'

# Inicializando o bot
ShellBot.init --token "$bot_token" --monitor
mensagem(){
    ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "$1"
}
while :
do
    # Obtem as atualizações
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30
    # Lista as atualizações.
    for id in $(ShellBot.ListUpdates)
    do
    # bloco de instruções
    (
        #adcionar /algo se o usuario esquecer trocando ${message_text[$id]%%@*} por uma variavel
        case ${message_text[$id]%%@*} in 
            /start)
            ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "/youtube link \n/soundcloud link \n/spotyfi link \nex: /soundcloud https://soundcloud.com/awildzapdos/napstablook-battle-theme-undertale"
            ;;
            /soundcloud*) 
                IFS=' ' read l1 link <<< "${message_text[$id]}"
                [[ $link ]] && {
                    tratar=$(curl -s "https://soundcloudtomp3.app/download/?url=${link}" | egrep -o 'downloadFile(.)*\)')
                    tratar=${tratar##*\(\'}
                    tratar=${tratar%\',\'*}
                    ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "downloading"
                    curl -s "${tratar}" -o "${link##*/}.mp3"
                    [[ "${f5%.*}" ]] && {
                    IFS='/' read f1 f2 f3 f4 f5 <<< $link
                        echo "${f5%.*}.mp3"
                        ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio "@${f5%.*}.mp3"
                        rm "${f5%. }.mp3"
                    } || {
                        ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "error, download fail!!!"
                    }
                    
                } || {
                    ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "error, download fail!!!"
                }

            ;;
            /youtube*)    
                [[ -a ${message_from_id[$id]} ]] || mkdir ${message_from_id[$id]}
                cd ${message_from_id[$id]}
                iFS=' ' read l1 link <<< "${message_text[$id]}"
                [[ $link ]] && {
                    ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "downloading"
                    youtube-dl -f 140 $link
                    [[ $(ls) ]] && {
                        ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio "@$(ls)"
                        cd ..
                        rm -r ${message_from_id[$id]}
                    } || {
                        ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "error, download fail!!!"
                    }
                    
                } || {
                    ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "error, download fail!!!"
                }
            ;;
            /spotyfi*)
                [[ -a ${message_from_id[$id]} ]] || mkdir ${message_from_id[$id]}
                cd ${message_from_id[$id]}
                iFS=' ' read l1 link <<< "${message_text[$id]}"
                [[ $link ]] && {
                    [[ "$(curl "${link}")" =~ \<title\>(.*)\<\/title\> ]] && busca="${BASH_REMATCH[1]%|*}"
                    [[ "$(curl -si "https://www.youtube.com/results?search_query=${busca// /\+}")" =~ /watch\?v=([a-zA-Z0-9_-]+) ]]
                    ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "downloading"
                    youtube-dl -f 140 "https://www.youtube.com${BASH_REMATCH[0]}"
                    [[ $(ls) ]] && {
                        ShellBot.sendAudio --chat_id ${message_chat_id[$id]} --audio "@$(ls)"
                        cd ..
                        [[ -a ${message_from_id[$id]} ]] && rm -r ${message_from_id[$id]}
                    } || {
                        ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "error, download fail!!!"
                    }
                    
                } || {
                    ShellBot.sendMessage --chat_id "${message_chat_id[$id]}" --text "error, download fail!!!"
                }

            ;;
            esac           
    ) &  
    done
done
