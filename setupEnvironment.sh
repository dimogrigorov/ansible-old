echo "Do you want to substitute /etc/ansible/hosts with the one in this folder y/n(if 'no' then use -i path_to_host_file)?"
read input
if [[ $input == 'y' ]]; then 
  sudo cp -f hosts /etc/ansible/hosts 
fi
#echo "Please enter path for ANSIBLE_HOME - leave blank for currrent directory: "
#read input_variable
#if [ $input_variable == ''] then {
#  input_variable=eval(pwd) 
#}
#export ANSIBLE_HOME=$input_variable
echo "Please enter Vault Password:"
read -s input_variable
echo "You entered: $input_variable"
export VAULT_PASSWORD=$input_variable
