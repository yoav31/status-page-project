deny[msg] {
    resource := resource_changes[_]
    action := resource.change.actions[_]
    action == "create" 
    
    resource.type == "aws_instance"
    allowed_types := {
        "t2.nano", "t2.micro", "t2.small", "t2.medium", 
        "t3.nano", "t3.micro", "t3.small", "t3.medium",
        "t3a.nano", "t3a.micro", "t3a.small", "t3a.medium"
    } 
    instance_type := resource.change.after.instance_type
    not allowed_types[instance_type]
    msg := sprintf("OPA Alert: Instance '%v' is trying to use '%v'. You cannot use instances larger than Medium!", [resource.name, instance_type])
}