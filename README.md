<img width=150 align="left" src="/docs/images/terra_logo_web_cut.png">
http://afbranco.github.io/Terra

Terra IoT System
=====

__Terra IoT System - A tiny virtual Machine for IoT/WSN that runs a reactive script language.__

The system is composed by three modules:

1. Terra compiler __terrac__ compiles the Terra script language based on Céu Language to the Terra Virtual Machine bytecode.
2. Terra Virtual Machine __TerraVM__ implements the bytecode Interpreter, the Céu Execution control, the user application code dissemination, and specific Terra Flavors Customizations.
3. Terra Control Tool __TerraControl__ is a java interface to control the remote script loading and user message monitoring.

