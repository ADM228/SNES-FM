import math

def logTableGenerate(scale : int) -> tuple[tuple, int, int]:
	PITCH_DIV = 256
	MUL_COEFF = 256
	maxDiff = 1000
	pitchNums = range(PITCH_DIV);
	pitchOffs = list(map(
		lambda x : 2**(x / (PITCH_DIV * scale)) - 1,
		pitchNums));
	divFactor = 1 / max(pitchOffs) 
	binDivFactor = 2**math.floor(math.log2(divFactor))
	while maxDiff > 2:
		finalPitchTable = list(map(
			lambda x : round(MUL_COEFF * binDivFactor * x),
			pitchOffs))
		staggerTable = list(map(
			lambda x, y: y - x, finalPitchTable,
			finalPitchTable[1:]))
		filteredStaggerTable = tuple(filter(
			lambda x : True if x[1] != 1 else False,
			enumerate(staggerTable)))

		maxDiff = max(staggerTable)
		if (maxDiff <= 2):
			if (maxDiff == 2):
				# this is an exp function
				# the difference of an exp function always increases
				# therefore once we start having 2s we stop having 0s
				changeIndex = staggerTable.index(2)
			else:
				changeIndex = -1
			break;
		binDivFactor *= 2

	outputTable = tuple(map(lambda x : x[0], filteredStaggerTable))
	return (outputTable, binDivFactor, changeIndex)


#config option names are preliminary btw

if __name__ == "__main__":
	scale = "0"
	while not (scale.isnumeric() and int(scale) >= 6 and int(scale) <= 96):
		scale = input("Please specify the scale (equal temperament): ")
	logTable, divFactor, changeIndex = logTableGenerate(int(scale))
	print("Code for insertion:")
	if (len(logTable) > 0):
		print("\tdb " + ", ".join(map(str, logTable)))
		print("\tdb 0")
	else:
		# Actually occurs in TET89
		print("\t!SNESFM_CFG_PITCHBEND_TABLE_DISABLE #= 1")
	print(f"\t!SNESFM_CFG_PITCH_OFFSET_DIVISOR #= {divFactor}")
	if (changeIndex >= 0):
		# Actually occurs in TET6
		print(F"\t!SNESFM_CFG_PITCHBEND_GEN_DIFF_CHANGE_IDX #= {changeIndex}")