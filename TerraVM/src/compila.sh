#!/usr/bin/env bash
exec > >(tee complog.txt)

# RF Power: 0 1 2 3 4 5 6 7 | default 3
RADIO_PWR=4
RADIO_PWR2=4
# LPL - Low Power Listening
LPL=NO


# NET BS Micaz 
echo "***********************"
echo "*** NET BS Micaz ****" 
make micaz  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraNet_micaz_bs.exe

# NET NOBS Micaz 
echo "***********************"
echo "*** NET NOBS Micaz MDA100 ****" 
make micaz  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MDA100 	TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraNet_micaz_100.exe
echo "***********************"
echo "*** NET NOBS Micaz MTS300CA ****" 
make micaz  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MTS300CA TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraNet_micaz_300a.exe
echo "***********************"
echo "*** NET NOBS Micaz MTS300CB ****" 
make micaz  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MTS300CB TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraNet_micaz_300b.exe

# NET BS Mica2 
echo "***********************"
echo "*** NET BS Mica2 ****" 
make mica2  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR2 TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraNet_mica2_bs.exe

# NET NOBS Mica2 
echo "***********************"
echo "*** NET NOBS Mica2 MDA100 ****" 
make mica2  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR2 SENSOR=MDA100 	TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraNet_mica2_100.exe
echo "***********************"
echo "*** NET NOBS Mica2 MTS300CA ****" 
make mica2  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR2 SENSOR=MTS300CA TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraNet_mica2_300a.exe
echo "***********************"
echo "*** NET NOBS Mica2 MTS300CB ****" 
make mica2  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR2 SENSOR=MTS300CB TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraNet_mica2_300b.exe

# NET BS Mica2Dot 
echo "***********************"
echo "*** NET BS Mica2Dot ****" 
make mica2dot  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR2 TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2dot/main.exe dist/bin/TerraNet_mica2dot_bs.exe

# NET NOBS Mica2Dot 
echo "***********************"
echo "*** NET NOBS Mica2Dot No_Sensor ****" 
make mica2dot  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR2 	TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2dot/main.exe dist/bin/TerraNet_mica2dot_xxx.exe

# NET BS TelosB 
echo "***********************"
echo "*** NET BS TelosB ****" 
make telosb  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR 					TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraNet_telosb_bs.exe

# NET NOBS TelosB 
echo "***********************"
echo "*** NET NOBS TelosB ****" 
make telosb  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR 					TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraNet_telosb.exe

# NET BS TelosB Full 
echo "***********************"
echo "*** NET BS TelosB Full ****" 
make telosb  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR 					TYPE=BS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraNet_telosb_full_bs.exe

# NET NOBS TelosB Full
echo "***********************"
echo "*** NET NOBS TelosB Full ****" 
make telosb  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR 					TYPE=NOBS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraNet_telosb_full.exe


# NET BS Iris 
echo "***********************"
echo "*** NET BS Iris ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_bs.exe

# NET NOBS Iris 
echo "***********************"
echo "*** NET NOBS Iris MDA100 ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MDA100 	TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_100.exe
echo "***********************"
echo "*** NET NOBS Iris MTS300CA ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MTS300CA TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_300a.exe
echo "***********************"
echo "*** NET NOBS Iris MTS300CB ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MTS300CB TYPE=NOBS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_300b.exe

# NET BS Iris HYB=NO
echo "***********************"
echo "*** NET BS Iris ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR TYPE=BS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_bs.exe

# NET NOBS Iris HYB=NO
echo "***********************"
echo "*** NET NOBS Iris HYB=NO MDA100 ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MDA100 	TYPE=NOBS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_100.exe
echo "***********************"
echo "*** NET NOBS Iris HYB=NO MTS300CA ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MTS300CA TYPE=NOBS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_300a.exe
echo "***********************"
echo "*** NET NOBS Iris HYB=NO MTS300CB ****" 
make iris  VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MTS300CB TYPE=NOBS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraNet_iris_300b.exe


# NET ALL TOSSIM 
echo "***********************"
echo "*** NET ALL TOSSIM ****" 
make micaz sim-sf VM=NET MODULES=MSGQ RFPOWER=$RADIO_PWR SENSOR=MDA100 TYPE=ALL HYB=YES QUEUE=SHORT
cp TOSSIM.py dist/sim/Net/TOSSIM.py
cp _TOSSIMmodule.so dist/sim/Net/_TOSSIMmodule.so




# GRP BS Micaz 
echo "***********************"
echo "*** GRP BS Micaz ****" 
make micaz  VM=GRP RFPOWER=$RADIO_PWR TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraGrp_micaz_bs.exe

# GRP NOBS Micaz 
echo "***********************"
echo "*** GRP NOBS Micaz MDA100 ****" 
make micaz  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MDA100 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraGrp_micaz_100.exe
echo "***********************"
echo "*** GRP NOBS Micaz MTS300CA ****" 
make micaz  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MTS300CA 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraGrp_micaz_300a.exe
echo "***********************"
echo "*** GRP NOBS Micaz MTS300CB ****" 
make micaz  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MTS300CB 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/micaz/main.exe dist/bin/TerraGrp_micaz_300b.exe

# GRP BS Mica2 
echo "***********************"
echo "*** GRP BS Mica2 ****" 
make mica2  VM=GRP  TYPE=BS RFPOWER=$RADIO_PWR2   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraGrp_mica2_bs.exe

# GRP NOBS Mica2 
echo "***********************"
echo "*** GRP NOBS Mica2 MDA100 ****" 
make mica2  VM=GRP SENSOR=MDA100 RFPOWER=$RADIO_PWR2 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraGrp_mica2_100.exe
echo "***********************"
echo "*** GRP NOBS Mica2 MTS300CA ****" 
make mica2  VM=GRP SENSOR=MTS300CA RFPOWER=$RADIO_PWR2 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraGrp_mica2_300a.exe
echo "***********************"
echo "*** GRP NOBS Mica2 MTS300CB ****" 
make mica2  VM=GRP SENSOR=MTS300CB RFPOWER=$RADIO_PWR2 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2/main.exe dist/bin/TerraGrp_mica2_300b.exe

# GRP BS Mica2Dot 
echo "***********************"
echo "*** GRP BS Mica2Dot ****" 
make mica2dot  VM=GRP  TYPE=BS RFPOWER=$RADIO_PWR2   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2dot/main.exe dist/bin/TerraGrp_mica2dot_bs.exe

# GRP NOBS Mica2Dot 
echo "***********************"
echo "*** GRP NOBS Mica2Dot No_Sensor ****" 
make mica2dot  VM=GRP RFPOWER=$RADIO_PWR2 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/mica2dot/main.exe dist/bin/TerraGrp_mica2dot_xxx.exe

# GRP BS TelosB 
echo "***********************"
echo "*** GRP BS TelosB ****" 
make telosb  VM=GRP RFPOWER=$RADIO_PWR 						TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraGrp_telosb_bs.exe

# GRP NOBS TelosB 
echo "***********************"
echo "*** GRP NOBS TelosB ****" 
make telosb  VM=GRP RFPOWER=$RADIO_PWR 						TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraGrp_telosb.exe

# GRP BS TelosB Full
echo "***********************"
echo "*** GRP BS TelosB Full ****" 
make telosb  VM=GRP RFPOWER=$RADIO_PWR 						TYPE=BS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraGrp_telosb_full_bs.exe

# GRP NOBS TelosB Full
echo "***********************"
echo "*** GRP NOBS TelosB Full ****" 
make telosb  VM=GRP RFPOWER=$RADIO_PWR 						TYPE=NOBS HYB=NO QUEUE=SHORT LPL=$LPL
cp build/telosb/main.exe dist/bin/TerraGrp_telosb_full.exe

# GRP BS Iris 
echo "***********************"
echo "*** GRP BS Iris ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR TYPE=BS   HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_bs.exe

# GRP NOBS Iris 
echo "***********************"
echo "*** GRP NOBS Iris MDA100 ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MDA100 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_100.exe
echo "***********************"
echo "*** GRP NOBS Iris MTS300CA ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MTS300CA 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_300a.exe
echo "***********************"
echo "*** GRP NOBS Iris MTS300CB ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MTS300CB 	TYPE=NOBS HYB=YES QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_300b.exe

# GRP BS Iris HYB=NO
echo "***********************"
echo "*** GRP BS Iris HYB=NO ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR TYPE=BS   HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_bs.exe

# GRP NOBS Iris 
echo "***********************"
echo "*** GRP NOBS Iris HYB=NO MDA100 ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MDA100 	TYPE=NOBS HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_100.exe
echo "***********************"
echo "*** GRP NOBS Iris HYB=NO MTS300CA ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MTS300CA 	TYPE=NOBS HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_300a.exe
echo "***********************"
echo "*** GRP NOBS Iris HYB=NO MTS300CB ****" 
make iris  VM=GRP RFPOWER=$RADIO_PWR SENSOR=MTS300CB 	TYPE=NOBS HYB=NO QUEUE=SHORT LPL=$LPL
cp build/iris/main.exe dist/bin/TerraGrp_iris_300b.exe


# GRP ALL TOSSIM 
echo "***********************"
echo "*** GRP ALL TOSSIM ****" 
make micaz sim-sf VM=GRP RFPOWER=$RADIO_PWR SENSOR=MDA100 TYPE=ALL HYB=YES QUEUE=SHORT
cp TOSSIM.py dist/sim/Grp/TOSSIM.py
cp _TOSSIMmodule.so dist/sim/Grp/_TOSSIMmodule.so


echo ""
echo ""
echo "===================================================================="
echo ""
echo " Alocação de memória"
echo ""
grep complog.txt -e"Config" -B3 -e"RAM" -e"VM_MEM " | grep -e"Config" -v | grep -e"\*\*\*" -e"ROM" -e"RAM" -e"VM_MEM "
echo ""
echo "===================================================================="

