shopt -s expand_aliases
# Terra alias support
alias avrora='java -jar /home/terra/TerraNet/sim/avrora-beta-1.7.115.jar'
alias TerraControl='java -jar /home/terra/TerraNet/tools/TerraVMControl.jar'
alias terrac='/home/terra/TerraNet/terra/terrac'
alias sf='java net.tinyos.sf.SerialForwarder'

function sfmica() { sf -comm serial@/dev/ttyUSB"$@":micaz ;}
function sftelos() { sf -comm serial@/dev/ttyUSB"$@":telosb ;}
function sfTBufrj() { sf -comm network@manaus.voip.nce.ufrj.br:$@;}
function sfTBpuc() { sf -comm network@testbed.inf.puc-rio.br:$@;}
