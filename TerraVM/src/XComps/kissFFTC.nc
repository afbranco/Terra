configuration kissFFTC{
	provides interface kissFFT;
}
implementation{
	components kissFFTP;
	kissFFT = kissFFTP.KF;
}