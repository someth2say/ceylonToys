import ceylon.random {
	DefaultRandom
}
"Run the module `rectangle`."

shared alias Point => [Integer, Integer];

shared void run() {
	Point boundaries = [100_000, 500];
	Rectangle initial = Rectangle(boundaries);
	//Point[] exclusions = [[1, 4], [2, 3], [3, 2], [5, 1], [5, 2]];
	//Point[] exclusions = [
	//	[55132, 204],
	//	[78218, 384],
	//	[18163, 143],
	//	[18226, 342],
	//	[45698, 283],
	//	[29601, 317],
	//	[82323, 351],
	//	[12275, 71],
	//	[49197, 27],
	//	[38040, 229],
	//	[9289, 251],
	//	[55710, 272],
	//	[17389, 172],
	//	[58191, 353],
	//	[64292, 429],
	//	[90150, 144],
	//	[33094, 173],
	//	[86204, 393],
	//	[27515, 134],
	//	[7114, 248],
	//	[55336, 426],
	//	[50112, 44],
	//	[23451, 213],
	//	[53234, 448],
	//	[5359, 409],
	//	[10658, 489],
	//	[74790, 139],
	//	[1257, 80],
	//	[16712, 219],
	//	[97680, 453],
	//	[64070, 450],
	//	[97018, 317],
	//	[63879, 433],
	//	[10338, 246],
	//	[89197, 381],
	//	[64409, 473],
	//	[98975, 112],
	//	[23446, 413],
	//	[78805, 47],
	//	[13606, 219],
	//	[73311, 177],
	//	[82271, 481],
	//	[93278, 70],
	//	[40711, 310],
	//	[26204, 260],
	//	[4675, 327],
	//	[80132, 205],
	//	[95632, 268],
	//	[13925, 137],
	//	[70917, 419],
	//	[63916, 62],
	//	[11731, 215],
	//	[91444, 414],
	//	[53520, 154],
	//	[64196, 482],
	//	[87560, 364],
	//	[16574, 458],
	//	[79630, 231],
	//	[8863, 147],
	//	[15905, 262],
	//	[11244, 427],
	//	[95233, 267],
	//	[62719, 199],
	//	[67316, 211],
	//	[49606, 11],
	//	[71766, 182],
	//	[55717, 428],
	//	[21542, 223],
	//	[68128, 178],
	//	[47821, 174],
	//	[16655, 277],
	//	[25740, 203],
	//	[7081, 85],
	//	[38296, 135],
	//	[68885, 192],
	//	[89271, 471],
	//	[76262, 285],
	//	[68685, 317],
	//	[68535, 291],
	//	[30000, 325],
	//	[31311, 3],
	//	[76022, 316],
	//	[61133, 187],
	//	[22342, 71],
	//	[27104, 213],
	//	[43216, 476],
	//	[64475, 183],
	//	[74473, 136],
	//	[3700, 211],
	//	[72270, 450],
	//	[76226, 225],
	//	[73560, 66],
	//	[21125, 183],
	//	[88923, 24],
	//	[64041, 43],
	//	[52711, 85],
	//	[37088, 48],
	//	[3148, 384],
	//	[57383, 140],
	//	[23814, 410]
	//];
	
	print("Generating...");
	variable {Point*} exclusions = generateRandomPoints(initial, 5000);
	print(exclusions);
	
	value startTime = system.milliseconds;
	
	
	variable {Rectangle*} potentialAreas = {initial};
	exclusions = exclusions.sort(byIncreasing((Point e) => e[0]));
	print(exclusions);

	for (currentPoint in exclusions) {
		variable {Rectangle*} areasWOcurrentPoint = {};
		for (Rectangle curentArea in potentialAreas) {
			{Rectangle+} newAreas = curentArea.splitOnPoint(currentPoint);
			{Rectangle*} newAreasOnXAxis = newAreas.filter((Rectangle element) => element.downLeft[1] == 0);
			areasWOcurrentPoint = areasWOcurrentPoint.chain(newAreasOnXAxis);
		}
		potentialAreas = areasWOcurrentPoint;
		print("``potentialAreas.size`` areas remaining.");
	}
	
	print("Can split to ``potentialAreas.size`` areas");
	value sortedAreas = potentialAreas.sort(byDecreasing(Rectangle.area));
	value endTime = system.milliseconds;

	print("Sorted(``endTime-startTime`` ms)");
	print(sortedAreas.first?.area);
}

{Point*} generateRandomPoints(Rectangle area, Integer howMany) => {for ( num in 1..howMany) [DefaultRandom().nextInteger(area.width)+area.downLeft[0], DefaultRandom().nextInteger(area.height)+area.downLeft[1]]};

shared class Rectangle(shared Point topRight, shared Point downLeft = [0, 0]) {
	
	assert (downLeft[0] <= topRight[0] && downLeft[1] <= topRight[1]);
	
	shared Integer height = topRight[1] - downLeft[1];
	shared Integer width = topRight[0] - downLeft[0];
	shared Integer area => (height) * (width);
	
	shared Boolean includesPointHoritzontal(Point point)
			=> downLeft[0] < point[0] && topRight[0] > point[0];
	
	shared Boolean includesPointVertical(Point point)
			=> downLeft[1] < point[1] && topRight[1] > point[1];
	
	shared Boolean includesPoint(Point point) => includesPointHoritzontal(point) && includesPointVertical(point);
	
	shared {Rectangle+} splitVertical(Point point) {
		Rectangle leftSide = Rectangle([point[0], topRight[1]], downLeft);
		Rectangle rightSide = Rectangle(topRight, [point[0], downLeft[1]]);
		return {leftSide, rightSide};
	}
	
	shared {Rectangle+} splitHoritzontal(Point point) {
		Rectangle lowerSide = Rectangle([topRight[0], point[1]], downLeft);
		return {lowerSide};
		//Rectangle upperSide = Rectangle(topRight, [downLeft[0], point[1]]);
		//return {upperSide, lowerSide};
	}
	shared {Rectangle+} splitOnPoint(Point point) {
		if (includesPoint(point)) {
			variable {Rectangle*} result = {};
			if (includesPointHoritzontal(point)) {
				result = result.chain(splitVertical(point));
			}
			if (includesPointVertical(point)) {
				result = result.chain(splitHoritzontal(point));
			}
			assert (is {Rectangle+} iterable = result);
			return iterable;
		} else {
			return {this};
		}
	}
	
	string => "[``downLeft``,``topRight``]";
}
