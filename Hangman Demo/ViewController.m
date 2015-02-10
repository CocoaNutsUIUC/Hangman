//
//  ViewController.m
//  Hangman Demo
//
//  Created by Justin Loew on 7/26/14.
//  Copyright (c) 2014 Justin Loew. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *guessesRemainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *notPresentLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *letterLabels;
@property (weak, nonatomic) IBOutlet UITextField *guessTextField;

@property NSString *chosenWord;
@property BOOL gameOver;

- (void)setUp;
- (NSString *)chooseRandomWord;
- (void)unmaskWordForLetter:(unichar)letter;
- (BOOL)gameHasBeenWon;
- (void)endGame;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.guessTextField.delegate = self;
	
	[self setUp];
}

- (void)setUp {
	self.guessesRemainingLabel.text = @"XXXXX";
	
	self.notPresentLabel.text = @"";
	
	self.statusLabel.text = @"Guess a letter below!";
	
	self.gameOver = NO;
	
	self.guessTextField.placeholder = @"Guess!";
	
	self.chosenWord = [self chooseRandomWord];
	
	// Set the labels to show the word when guessed
	for (UILabel *label in self.letterLabels) {
		label.text = @"";
		label.hidden = YES;
	}
	for (NSUInteger i = 0; i < [self.chosenWord length]; i++) {
		[self.letterLabels[i] setText:@"_"];
		[self.letterLabels[i] setHidden:NO];
	}
}

- (NSString *)chooseRandomWord {
	NSString *wordlistFilePath = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"txt"];
	
	NSString *wordlistContents = [NSString stringWithContentsOfFile:wordlistFilePath encoding:NSUTF8StringEncoding error:NULL];
	NSArray *wordsInList = [wordlistContents componentsSeparatedByString:@"\n"];
	
	NSUInteger randomIndex = (NSUInteger) (arc4random() % [wordsInList count]);
	
	return [wordsInList[randomIndex] uppercaseString];
}

- (void)unmaskWordForLetter:(unichar)letter {
	NSString *letterStr = [NSString stringWithFormat:@"%C", letter];	// more convenient to work with
	
	BOOL letterIsPresent = NO;
	for (int i = 0; i < self.chosenWord.length; i++) {
		if ([self.chosenWord characterAtIndex:i] == letter) {
			letterIsPresent = YES;
			[self.letterLabels[i] setText:letterStr];
		}
	}
	
	// Incorrect guess handling
	if (!letterIsPresent) {
		if ([self.notPresentLabel.text containsString:letterStr]) {
			self.statusLabel.text = @"You already guessed that letter!";
		} else {
			self.notPresentLabel.text = [self.notPresentLabel.text stringByAppendingString:letterStr];
			self.guessesRemainingLabel.text = [self.guessesRemainingLabel.text substringFromIndex:1];	// remove one guess
			if (self.guessesRemainingLabel.text.length == 0) {
				[self endGame];
			} else {
				self.statusLabel.text = @"Incorrect! Try again.";
			}
		}
	} else if ([self gameHasBeenWon]) {
		[self endGame];
	}
}

- (BOOL)gameHasBeenWon {
	for (int i = 0; i < self.chosenWord.length; i++) {
		NSString *letter = [self.letterLabels[i] text];
		if ([letter isEqualToString:@"_"]) {
			return NO;
		}
	}
	
	return YES;
}

- (void)endGame {
	for (UILabel *label in self.letterLabels) {
		label.hidden = NO;
	}
	
	if ([self gameHasBeenWon]) {
		self.statusLabel.text = @"You win! Play again?";
	} else {
		self.statusLabel.text = @"Game Over :(";
	}
	
	self.guessTextField.placeholder = @"Type to play";
	
	self.gameOver = YES;
	
	[self.guessTextField resignFirstResponder];
}

#pragma mark - Text Field Delegate stuff

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//	return !self.gameOver;
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (self.gameOver) {
		[self setUp];
	}
	
	unichar letter = [string characterAtIndex:0];
	[self unmaskWordForLetter:letter];
	
	return NO;
}

@end
