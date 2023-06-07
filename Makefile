path_kill_idle =$(shell pwd)/kill_idle.sh
base_output=build
output_dir=${base_output}/cluster
YAML_FILE= my.yaml

run_toolkit: ${YAML_FILE}
	ghpc  ${YAML_FILE} -w -o ${base_output} --vars path_kill_idle=${path_kill_idle}


#NETWORK
build_network:	run_toolkit
	terraform  -chdir=${output_dir}/network init
	terraform  -chdir=${output_dir}/network validate
	terraform  -chdir=${output_dir}/network apply --auto-approve


#FILESTORE
build_filestore:	build_network
	ghpc export-outputs ${output_dir}//network
	ghpc import-inputs ${output_dir}//filestore
	terraform  -chdir=${output_dir}/filestore init
	terraform  -chdir=${output_dir}/filestore validate
	terraform  -chdir=${output_dir}/filestore apply --auto-approve

#FILESTORE
build_desktop:	build_filestore
	ghpc export-outputs ${output_dir}//network
	ghpc export-outputs ${output_dir}//filestore
	ghpc import-inputs ${output_dir}//desktop
	terraform  -chdir=${output_dir}/desktop init
	terraform  -chdir=${output_dir}/desktop validate
	terraform  -chdir=${output_dir}/desktop apply --auto-approve



# Provide startup script to Packer
build_image: build_filestore
	ghpc export-outputs ${output_dir}/network
	ghpc  export-outputs  ${output_dir}/filestore
	ghpc import-inputs  ${output_dir}/disk
	terraform -chdir=${output_dir}/disk init
	terraform -chdir=${output_dir}/disk validate
	terraform -chdir=${output_dir}/disk apply --auto-approve
	ghpc export-outputs ${output_dir}/disk  
	cd ${output_dir}/packer/custom-image &&\
	packer init . &&\
	packer validate . &&\
	packer build . &&\
	cd -

build_cluster:	build_image
	ghpc export-outputs ${output_dir}/network
	ghpc  export-outputs ${output_dir}/filestore
	ghpc export-outputs ${output_dir}/disk
	ghpc import-inputs ${output_dir}/cluster
	terraform -chdir=${output_dir}/cluster init
	terraform -chdir=${output_dir}/cluster validate
	terraform -chdir=${output_dir}/cluster apply  --auto-approve



destroy_cluster: 
	terraform -chdir=${output_dir}/cluster destroy --auto-approve 
destroy_image:
	terraform -chdir=${output_dir}/disk destroy --auto-approve
destroy_desktop: 
	terraform -chdir=${output_dir}/desktop destroy --auto-approve
destroy_filestore: destroy_cluster destroy_desktop
	terraform -chdir=${output_dir}/filestore destroy --auto-approve
destroy_network: destroy_filestore
	terraform -chdir=${output_dir}/network destroy --auto-approve
