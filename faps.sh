
#!/bin/bash
clear
YELLOW='[0;33m'
RED='[0;31m'
GREEN='[0;32m'
NC='[0m' # No Color

# Check if a server is running on a given port
function check_server() {
    if lsof -i:$1 > /dev/null; then
        echo -e "$2 ${GREEN}Running${NC} on port $1. 👌"
    else
        echo -e "$2 ${RED}Stopped${NC} on port $1. 🖕"
    fi
}

# Find a free port
find_free_port() {
    local port=5001
    while true; do
        # Try to bind to the port using nc (netcat)
        if ! nc -z 127.0.0.1 $port; then
            echo $port
            break
        fi
        ((port++))
    done
}

# Kill a process running on a given port
kill_port() {
    local port=$1
    if lsof -i:$port > /dev/null; then
        kill $(lsof -t -i:$port)
    fi
}

while true; do
    
    echo "Select an option:"
    echo "1 -  Server start🚀"
    echo "2 -  Server status⭕"
    echo "3 -  ArgoCD Image Updater Live Logs📜"
    echo "4 -  ArgoCD Rollout🔄"
    echo "5 -  Make New Image Tag and Push to Docker Hub🐳"
    echo "6 -  Test ArgoCD Image Updater🔎"
    echo "7 -  ArgoCD"
    echo "8 -  kill port"
    echo "0 -  Exit🚪"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            clear
            echo "Starting servers..."
            kill_port 8080
            kubectl port-forward -n argocd svc/argocd-server 8080:443 & 
            sleep 1
            
            kill_port 9090
            kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090 &
            sleep 1
            
            kill_port 8085
            kubectl port-forward service/prometheus-grafana 8085:80 &
            sleep 1
            
            echo -e "${GREEN}Nice👌!!${NC} All servers are up and running. 🚀"            
            ;;
        2)
            clear
            echo "Checking server status..."
            check_server 8080 "ArgoCD Server"
            check_server 9090 "Prometheus Server"
            check_server 8085 "Grafana Server"
            ;;
        3)
            clear
            echo "Fetching ArgoCD Image Updater Live Log..."
            kubectl logs -f --selector app.kubernetes.io/name=argocd-image-updater -n argocd
            ;;
        4)  
            clear
            while true; do
                echo "ArgoCD Rollout Options:"
                echo "1 - Getting All Rollouts"
                echo "2 - Watching Rollouts👀"
                echo "3 - Running Dashboard on Port 3100"
                echo "0 - Back to main menu⬅️"
                read -p "Select an option: " rollout_choice

                case $rollout_choice in
                    1)
                        clear
                        kubectl get rollout -n argo-rollout-app
                        ;;
                    2)
                        clear
                        kubectl get rollout -n argo-rollout-app
                        read -p "Enter the rollout name: " rollout_name
                        kubectl argo rollouts get rollout -n argo-rollout-app $rollout_name -w
                        ;;
                    3)
                        clear
                        kill_port 3100
                        sleep 1
                        kubectl argo rollouts dashboard 3100
                        ;;
                    0)
                        clear
                        break
                        ;;
                    *)
                        clear
                        echo "${RED}Invalid Number, please try again.${NC}"
                        ;;
                esac
            done
            ;;
        5)
            clear
            read -p "Enter the Tag following SEV: " tag_name
            docker tag nginx:1.23.4 ghalamif/imagefaps:$tag_name
            sleep 1
            docker push ghalamif/imagefaps:$tag_name &
            sleep 5
            ;;
        6)
            clear
            argocd-image-updater test ghalamif/imagefaps
            ;;
        7)
            clear
            while true; do
                echo "ArgoCD Options:"
                echo "1 - List of Apps"
                echo "2 - Updating the App"
                echo "3 - Syncing the App"
                echo "4 - Getting the App Info"
                echo "5 - Getting the Image updater App Operation"
                echo "6 - Hard Refreshing the Image updater App"
                echo "7 - Getting the Image Updater Deployment"
                echo "8 - Back to main menu⬅️"
                read -p "Select an option: " argocd_choice

                case $argocd_choice in
                    1)
                        clear
                        argocd app list
                        ;;
                    2)
                        clear
                        kubectl apply -f ~/prfaps/application.yaml
                        sleep 2
                        ;;
                    3)
                        clear
                        argocd app list
                        sleep 1
                        read -p "Enter the app name to get its Info: " app_name
                        argocd app get $app_name -o wide
                        read -p "Enter the app name: " app_name_sync
                        argocd app sync $app_name_sync &
                        sleep 5
                        ;;
                    4)
                        clear
                        argocd app list
                        sleep 1
                        read -p "Enter the app name to get its Info: " app_name
                        argocd app get $app_name -o wide
                        ;;
                    5)
                        clear
                        argocd app get argo-image-updater2-app --show-operation
                        ;;
                    6)
                        clear
                        argocd app get argo-image-updater2-app --hard-refresh
                        ;;  
                    7)
                        clear
                        kubectl get deployment image-updater-deployment -n argo-image-updater2-app -o yaml
                        ;;       
                    0)
                        clear
                        break
                        ;;    
                    *)
                        clear
                        echo "${RED}Invalid Number, please try again.${NC}"
                        ;;
                esac
            done
            ;;

        8)
            clear
            read -p "Enter the port number to kill: " port_number
            kill_port $port_number
            ;;   
        0)
            clear
            echo "You Exited From ${GREEN}FAPS${NC}. 👋"
            exit 0
            ;;
        *)
            clear
            echo "${RED}Invalid Number, please try again.${NC}"
            ;;
    esac
done
