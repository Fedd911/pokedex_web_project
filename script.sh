#!/bin/bash

#Creates a cluster using the 'eksctl create cluster' command.
function create_cluster {

        read -p "Enter the name of your cluster: " clusterName
        read -p "Enter the region for your cluster: " clusterRegion
        read -p "Enter the name of your node group: " nodeGroupName
        read -p "Enter the type of EC2 instance type for the node('t3.medium' recommended): " nodeType
        read -p "Enter the amount of nodes to be deployed: " nodeAmount

        eksctl create cluster --name "$clusterName" --region "$clusterRegion" --nodegroup-name "$nodeGroupName" --node-type "$nodeType" --nodes "$nodeAmount"

}

# Iterates through a directory and applies 'kubectl apply -f' to all the .yaml files. 
# First searches for 'configmap' and 'secret' files, and invokes them if they exist.
function deploy {

        CONFIGMAP=$(ls $DIR | grep configmap)
        SECRET=$(ls $DIR | grep secret)

        kubectl apply -f "$CONFIGMAP"
        kubectl apply -f "$SECRET"

        shopt -s nullglob
    
        for file in "$DIR";  do
                if [[ "$file" == *".yaml"* || "$file" != *"configmap"* || "$file" != *"secret"* ]]; then
                kubectl apply -f  "$file"
                sleep 1
                fi
        done
}

# Checks if the provided Directory contains .yaml files, after which invokes the deploy function.
function init {

        if [[ -z $(ls $DIR | grep .yaml) ]]; then
        echo "ERROR: There are no .yaml files in the provided directory!!"
        echo "Provide a valid directory instead"

else
        deploy
fi
}

# Waits for the pods and services to be up and running, and then goes into the pod that contains the frontend service in order to change
# the API variable with the one AWS generates from the LoadBalancer.
# Otherwise the browser will not have access to the backend API. 
function configure_API {

        while true; do

        echo "Waiting for the front-end node to be in 'Running' state in order to change the API variable in the frontend...."

        PODNAME=$(kubectl get pod | grep frontend | awk '{print $1}')

        if [[ $(kubectl get pod | grep "$PODNAME" | grep Running) ]]; then

                while true; do

                        echo "Waiting for the service to assign an External IP before proceeding...."
                        echo

                        FRONTEND_DNS=$(kubectl get service | grep frontend | awk '{print "http://" $4}')
                        BACKEND_DNS=$(kubectl get service | grep backend | awk '{print $4":8080"}')

                        if [[ "$FRONTEND_DNS" != "http://<pending>" && "$BACKEND_DNS" != "<pending>:8080" ]]; then

                                break

                        fi
                        sleep 5
                done

                ##############

                kubectl exec  "$PODNAME" -- sh -c "sed -i 's|http://localhost:8080/pokemons|http://"$BACKEND_DNS"|' /usr/share/nginx/html/index.js"

                if [[ $? ]]; then
                        echo
                        echo "API Configured!!!"
                        echo
                        echo "The web app can be accessed via the following url: $FRONTEND_DNS"
                        echo
                fi
                break
        fi
        sleep 3
done

}


##################################### MAIN LOGIC #############################################################


        echo "--------------------------------------------------"
        echo
        echo "Before the script runs, provide the path to the directory that contains the .yaml configurations for the cluster."
        echo
        echo "--------------------------------------------------"
        read DIR

        create_cluster
        init
        configure_API