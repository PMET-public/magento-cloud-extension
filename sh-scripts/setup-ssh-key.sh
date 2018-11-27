printf "\nCreating and adding ssh key to cloud account ...\n"

if [ ! -f ~/.ssh/id_rsa.magento ]; then
  ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa.magento;
fi
  
~/.magento-cloud/bin/magento-cloud ssh-key:add ~/.ssh/id_rsa.magento.pub --yes
