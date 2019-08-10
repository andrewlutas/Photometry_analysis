# Photometry analysis
photometry analysis
Stephen Zhang 7/30/2019

Analysis for two-color photometry in the Andermann lab
* Supports data that collected with or without using a lock-in amplifier
* Supports quadratic demodulation
* Supports pre-filtering and pre-smoothing before alignment. These steps only affects the coefficients that are used for alignment and not the data traces themselves
* Supports pre-flattening before alignment. This step is also applied to the data traces themselves.
* Supports several linear forms of alignment and straight-up ratio metric calculations
* Supports using all, a single segment, or multiple segments of the data for alignment (with gui)
* Supports post-filtering and post-flattening after alignment

If you use the **square-wave photometry cubes**:

Sample:
![Square-box data sample](https://github.com/xzhang03/Photometry_analysis/blob/master/Sample%20images/Preprocesed%20square-wave%20data.png)
1. Run tcpPreprocess
2. Run tcpAlign

If you use **lock-in amplifiers**:
1. Run tcpAlign

If you use the **sine-wave photometry cubes**:
1. Run tcpDemodulation
3. Run tcpAlign
