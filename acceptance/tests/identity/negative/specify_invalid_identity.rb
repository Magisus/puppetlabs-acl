test_name 'Windows ACL Module - Negative - Specify Invalid Identity'

confine(:to, :platform => 'windows')

#Globals
target_parent = 'c:/temp'
target = 'c:/temp/specify_invalid_ident.txt'
user_id = "user_not_here"

file_content = 'Car made of cats.'
verify_content_command = "cat /cygdrive/c/temp/specify_invalid_ident.txt"
file_content_regex = /#{file_content}/

#Manifest
acl_manifest = <<-MANIFEST
file { '#{target_parent}':
  ensure => directory
}

file { '#{target}':
  ensure  => file,
  content => '#{file_content}',
  require => File['#{target_parent}']
}

acl { '#{target}':
  permissions => [
  	{ identity => '#{user_id}', rights => ['full'] },
  ],
}
MANIFEST

#Tests
agents.each do |agent|
  step "Execute Manifest"
  on(agent, puppet('apply', '--debug'), :stdin => acl_manifest) do |result|
    assert_match(/Error: Failed to set permissions for 'user_not_here'/, result.stderr, 'Expected error was not detected!')
  end

  step "Verify File Data Integrity"
  on(agent, verify_content_command) do |result|
    assert_match(file_content_regex, result.stdout, 'Expected file content is invalid!')
  end
end
