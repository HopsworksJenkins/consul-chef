# User certs must belong to consul group to be able to rotate x509 material
group node['consul']['group'] do
    action :modify
    members node['kagent']['certs_user']
    append true
    not_if { node['install']['external_users'].casecmp("true") == 0 }
end

hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:8181" 
if node.attribute? "hopsworks"
  if node["hopsworks"].attribute? "https" and node["hopsworks"]['https'].attribute? ('port')
    hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node['hopsworks']['https']['port']}"
  end
end

crypto_dir = x509_helper.get_crypto_dir(node['consul']['home'])
kagent_hopsify "Generate x.509" do
    user node['consul']['user']
    group node['consul']['group']
    crypto_directory crypto_dir
    hopsworks_alt_url hopsworks_alt_url
    action :generate_x509
    not_if { conda_helpers.is_upgrade || node["kagent"]["test"] == true }
end