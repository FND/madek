require 'rubygems'
require Rails.root+'features/support/personas' 
Persona.create("Adam") # Admin should be created first, he setting up the application
Persona.create("Normin")
Persona.create("Petra")
Persona.create("Beat")
Persona.create("Liselotte")
Persona.create("Norbert")