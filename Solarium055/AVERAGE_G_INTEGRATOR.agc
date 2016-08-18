### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	AVERAGE_G_INTEGRATOR.agc
# Purpose:	Part of the source code for Solarium build 55. This
#		is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), for Apollo 6.
# Assembler:	yaYUL --block1
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Solarium055/
# Mod history:	2009-10-01 JL	Created.

## Page 746

#	ROUTINE CALCRVG INTEGRATES THE EQUATIONS OF MOTION BY AVERAGING THE THRUST AND GRAVITATIONAL ACCELERA-
# TIONS OVER A TIME INTERVAL, DELTAT
#	FOR THE EARTH-CENTERED GRAVITATIONAL FIELD THE PERTURBATION DUE TO OBLATENESS IS COMPUTED TO THE FIRST
# HARMONIC COEFFICIENT J
#	ROUTINE NORMLISE MUST BE CALLED PRIOR TO THE FIRST ENTRY INTO CALCRVG. IT REQUIRES RN SCALED TO 2(+29)M
# IT LEAVES RN NORMALISED, SO THAT THE SCALED MAGNITUDE OF THE VECTOR CONTAINS ONE LEADING ZERO, BY SHIFTING THE
# VECTOR LEFT N BINARY PLACES
#	ROUTINE CALCRVG REQUIRES
#		1) THRUST ACCELERATION INCREMENTS IN DELV SCALED SAME AS PIPAX,Y,Z
#		2) VN SCALED AT 2(+7) M/CS
#		3) ADDRESS OF CALCGLUN OR CALCGEAR IN CALCG
#		4) DELTAT SCALED AT 2(+9) CS
#		5) PUSH-DOWN COUNTER SET TO ZERO
# IT LEAVES UPDATED RN, SCALED AT 2(29-N) M, VN, AND GRAVITY SCALED AT 2(-5) M/CS/CS


#	CONTINUE ON IN BANK 30.

NORMLISE	ABVAL	3		# COUNT NUMBER OF LEADING ZEROS IN
		TSLC	INCR,1		# ABVAL (RN) AND STORE -N(=2-M) IN NSHIFT
		SXA,1	INCR,1		# RN MUST BE SCALED AT 2(+29)M
		SXA,1	ITA
			RN
			X1
			2
			NSHIFT		# SAVE C(X1)=-N
			14D
			XSHIFT		# SAVE C(X1) =14-N
			S2
		
		VMOVE	1
		VSLT*
			RN
			14D,1
		STORE	RN		# RN SCALED AT 2(29-N)METRES
		
		ITC	0
			CALCGRV1
		
		ITCI	0
			S2

## Page 747

CALCRVG		VXSC	0
			DELV
			KPIP		# DV TO PD SCALED AT 2(+4)M/CS
		
		VXSC	1
		LXA,1	BVSU
			GRAVITY
			DELTAT
			XSHIFT
			0		# (DV-(OLD GDT))/2 TO PD SCALED 2(+3)M/CS
		
		NOLOD	3
		VSRT	VAD
		VAD	ITA
			4
			VN
			DELTAT
			0,1
			RN
			S2
		STORE	RN1		# SCALED AT 2(29-N) METERS
		
		ITC	0
			CALCGRV1
		
		NOLOD	3
		VXSC	BVSU
		VAD	VSRT
		VAD
			DELTAT
			-		# (DV-(OLD GDT))/2
			-		# DV/2
			4
			VN
		STORE	VN1		# SCALED AT 2(+7) MET/CS
		
#  IN AVERAGE G, UP THE PHASE BITS BY 2 OF ACTIVE PROG BEFORE COPY CYCLE.

		EXIT	0
		
		INDEX	FIXLOC
		CS	S2		# SAVE NEG RETURN ADDRESS IN NON-VAC AREA.
CALCRVG2	TS	AVGRETRN	# SAVE NEGATIVE OF RETURN ADDRESS.

		CS	-PHASE1 +4	# PICK UP PHASES.
		AD	ONE		# INCREMENT BY 1.
		TC	NEWPHASE	# AND CALL ROUTINE TO CHANGE PHASE.
		OCT	00005
## Page 748
REFAZE6		INHINT
		CAF	ELEVEND
		TS	MPAC		# USE MPAC FOR LOOP COUNTER.
		INDEX	MPAC
		CS	RN1		# RN1 AND VN1 MUST BE IN ORDER.
		COM			# LEAVE RN1 ALONE  IN CASE OF RESTARTS.
		INDEX	MPAC		# SELECT THE HIGH TERM.
		TS	RN		# ...AND GO THRU COPY CYCLE.
		
		CCS	MPAC		# ARE WE DONE..
		TC	REFAZE6 +2	# NO, NOT YET.
		CS	BIT2		# YES, MPAC = 0.
		MASK	TMMARKER
		AD	BIT2		# SET BIT 2 TO ONE IN TMMARKER.
		TS	TMMARKER
					# WHAT ABOUT GRAVITY FOR RESTART..
		RELINT
		CS	AVGRETRN	# NEG OF ADDRESS WAS STORED.
		TC	BANKJUMP



ELEVEND		DEC	11		# 11D  (ELEVEN DECIMAL, OF COURSE.)



CALCGRAV	LXA,1	0
			XSHIFT

CALCGRV1	NOLOD	1
		UNIT
		STORE	UNITR
		
		DMOVE	1
		TSLT
			30D
			1
		STORE	RMAG		# SCALED AT 2(30-N)M
		
		TSLT	0
			28D
			2
		STORE	RMAGSQ		# SCALED AT 2(+50)M(+2)
		
		ITA	1
		XAD,1
			27D
			NSHIFT
## Page 749

CALCGEAR	DOT	0
			UNITR
			UNITW
		STORE	25D
		
		NOLOD	2
		DSQ	DMP
		TSLT	BDSU
			DP(5/8)
			4
			DP2(-3)
		
		DDV	1
		TSLT*
			J(RE)SQ		# SCALED AT 2(+40) M(+2)
			RMAGSQ
			0,1
		STORE	23D		# J(RE/RN) SQ SCALED AT 2(-3)
		
		NOLOD	2
		DMP	VXSC
		VAD
			-
			UNITR
			UNITR
		
		DMP	1
		VXSC	VAD
			23D
			25D
			UNITW
		
		DMOVE	1
		ITC
			MUEARTH
			MU/RSQ

CALCGLUN	VMOVE	0
			UNITR
		
		DMOVE	1
		INCR,1
			MUMOON
			6
		
MU/RSQ		NOLOD	2
		DDV	TSLT*
		VXSC
			RMAGSQ		# C(X1)=14-2N  (EARTH)
			5,1		#      =20-2N  (MOON)
## Page 750
		STORE	GRAVITY		# SCALED AT 2(-5) M/CS/CS
		
		ITCI	0
			27D

KPIP		2DEC	0.59904
DP2(-3)		2DEC	0.125
DP(5/8)		2DEC	0.625
MUEARTH		2DEC	.009063188 B-3	# SCALED AT 2(+45)M(+3)/CS(+2)
MUMOON		2DEC	0.007134481	# 4.90277800 E12	2(+36)M(+3)/CS(+2)
J(RE)SQ		2DEC	.06006663 B-3	# SCALED AT 2(+43)M(+2)

## Page 751

#	ROUTINE FOR FLIGHTS 501 &2 TO INCORPORATE STATE VECTOR UPDATE DURING AVERAGE G. EACH PASS THROUGH
# SERVICER COMES HERE TO SEE IF AN UPDATE IS READY.

		BANK	26

501UPCHK	DSU	2		# IF PIPTIME IS GREATER THAN OR EQUAL TO
		BMN	TEST		#   UPTIME, AND UPTIME IS NOT TOO OLD, AND
		DSU	BPL		#   UPDATFLG IS SET, DO THE UPDATE. UPTIME
			PIPTIME		#   IS NORMALLY SET TO POSMAX
			UPTIME		# POSMAX.
			REGSTEP
			UPDATFLG
			REGSTEP
			
			2.5SEC26
			BADUPTIM
		MXV	1		# TRANSFORM DATA IN STBUFF TO SM COORDS.
		VSLT
			STBUFF +6
			REFSMMAT
			1		# THIS ASSUMES THAT UPDATE SCALED 2(+7)M/CS
		STORE	VN1
		
		MXV	1
		VSLT
			STBUFF
			REFSMMAT
			2		# THIS ASSUMES THAT UPDATE SCALED 2(26)M
		STORE	RN1
		
		ITC	0		# CALCULATE THE ASSOCIATED GRAVITY VECTOR
			CALCGRAV	# FOR THE NEXT TIME STEP.
		
		EXIT	0
		
		TC	PHASCHNG	# UPDATE RESTART POINT BEFORE SETTING
		OCT	03005		# UPTIME TO SHOW THATTHE DATA HAS BEEN
		
REDO5.24	TC	FLAG1DWN	# INCORPORATED. ALSO, INDICATE THIS TO THE
		OCT	20000		# GROUND BY RESETTING UPDATFLG.
		
		CAF	POSMAX
		TS	UPTIME
		TS	UPTIME +1
		
		CS	501AVEX		# SET UP FOR AVERAGE G TO RETURN TO USUAL
		TC	POSTJUMP	# POINT IN SERVICER
		CADR	CALCGRV2

BADUPTIM	EXIT	0		# COME HERE IF UPTIME REPRESENTS PAST TIME
## Page 752
		TC	ALARM
		OCT	01411
		
		CAF	POSMAX
		TS	UPTIME
		TS	UPTIME +1
		
		TC	FLAG1DWN	# RESET UPDAT FLAG
		OCT	20000
		
		TC	INTPRET
		
		ITC	0
			REGSTEP

2.5SEC26	2DEC	250
501AVEX		CADR	AVGRET

## Page 753

# SIM FLIGHT SPECIAL



		BANK	31

MALSJOB		TC	INTPRET
		
		VXM	0
			STBUFF
			REFSMMAT
		STORE	STBUFF
		
		VXM	1
		VSLT
			STBUFF +6
			REFSMMAT
			1
		STORE	STBUFF +6
		
		EXIT	0
		
		TC	ENDOFJOB

