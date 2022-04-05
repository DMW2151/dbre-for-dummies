terraform {
  // Uses an experimental feature (new as of 4.X.X (?)), module_variable_optional_attrs, 
  // to allow for optional definition in objects
  experiments = [module_variable_optional_attrs]
}
