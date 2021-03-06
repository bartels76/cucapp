@import <Foundation/CPObject.j>
@import "CalculatorController.j"

@implementation CalculatorController : CPObject
{
    CPWindow    theWindow;
	CPTextField output;
	CPString    value;
	CPString    operation;
}

- (id) init {
	self = [super init];
	
	if(self) {
		[CPBundle loadCibNamed: "Calculator" owner: self];
		value = null;
		operation = null;
	}
	
	return self;
}

- (void) checkForOperation:(CPString)nextOperation {
	var text = [output stringValue];
	text = text + nextOperation;
	[output setStringValue: text];
}

- (IBAction) digitPressed:(CPButton)sender {
	var text = [output stringValue];
	if(text=='0') {
		text = '';
	}
	
	text = text + [sender title];
	[output setStringValue: text];
}

- (IBAction) addPressed:(CPButton)sender {
	[self checkForOperation: "+"];
}

- (IBAction) subtractPressed:(CPButton)sender {
	[self checkForOperation: "-"];
}

- (IBAction) multiplyPressed:(CPButton)sender {
	[self checkForOperation: "*"];
}

- (IBAction) dividePressed:(CPButton)sender {
	[self checkForOperation: "/"];
}

- (IBAction) negatePressed:(CPButton)sender {
	var text = [output stringValue];
	if(text!='0') {
		text = '-('+text+')';
		[output setStringValue: text];
	}
}

- (IBAction) clearPressed:(CPButton)sender {
	[output setStringValue: "0"];
}

- (IBAction) evalPressed:(CPButton)sender {
	var text = eval([output stringValue]);
	[output setStringValue: text];
}

@end