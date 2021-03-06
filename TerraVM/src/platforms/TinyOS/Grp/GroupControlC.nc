/*
  	Terra IoT System - A small Virtual Machine and Reactive Language for IoT applications.
  	Copyright (C) 2012-2017  Adriano Branco
	
	This file is part of Terra IoT.
	
	Terra IoT is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Terra IoT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Terra IoT.  If not, see <http://www.gnu.org/licenses/>.  
*/  
/***********************************************
 * wdvm - WSNDyn virtual machine project
 * July, 2012
 * Author: A.Branco
 * abranco at inf.puc-rio.br
 * *********************************************/
/*
 * Configuration: GroupControlC
 * Group control support
 * 
 */

configuration GroupControlC{
	provides interface GroupControl as GrCtl;
}
implementation{
	components GroupControlP;
	components BasicServicesC;
	
	GroupControlP.BSRadio -> BasicServicesC;
	GrCtl = GroupControlP.GrCtl;
	
}