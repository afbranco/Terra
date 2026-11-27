# Terra alias support
alias avrora='java -jar /home/terra/TerraNG/sim/avrora-beta-1.7.115.jar'
alias TerraControl='java -jar /home/terra/TerraNG/tools/TerraVMControl.jar'
alias terrac='/home/terra/TerraNG/terra/terrac'
alias sf='java net.tinyos.sf.SerialForwarder'

function sfmica() { sf -comm serial@/dev/ttyUSB"$@":micaz ;}
function sftelos() { sf -comm serial@/dev/ttyUSB"$@":telosb ;}
function sfTBufrj() { sf -comm network@ceunaterra.voip.ufrj.br:$@;}
function sfTBpuc() { sf -comm network@testbed.inf.puc-rio.br:$@;}
