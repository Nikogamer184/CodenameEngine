package funkin.ui;

import openfl.utils.Assets;
import openfl.utils.AssetLibrary;
import haxe.xml.Access;
import funkin.mods.LimeLibrarySymbol;
import funkin.mods.ModsAssetLibrary;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public function refreshAlphabetXML(path:String) {
		trace("Needs refresh!!");
		AlphaCharacter.__alphaPath = path;
		try {
			var xml = new Access(Xml.parse(Assets.getText(path)).firstElement());
			AlphaCharacter.boldAnims = [];
			AlphaCharacter.letterAnims = [];

			for(e in xml.elements) {
				var bold = e.name == "bold";
				var list = bold ? AlphaCharacter.boldAnims : AlphaCharacter.letterAnims;
				for(e in e.nodes.letter) {
					if (!e.has.char || !e.has.anim) continue;
					var name = e.att.char;
					var anim = e.att.anim;
					list[name] = anim;
				}
			}
		} catch(e) {
			trace(e.details());
		}
	}
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false)
	{
		super(x, y);

		_finalText = this.text = text;
		isBold = bold;

		var alphabetPath = Paths.xml("alphabet");
		if (alphabetPath != AlphaCharacter.__alphaPath) {
			refreshAlphabetXML(alphabetPath);
		} else {
			var libThing = new LimeLibrarySymbol(alphabetPath);
			if (libThing.library is AssetLibrary) {
				var library = cast(libThing.library, AssetLibrary);
				@:privateAccess
				if (library.__proxy != null && library.__proxy is AssetLibrary) {
					@:privateAccess
					library = cast(library.__proxy, AssetLibrary);
				}
				if (library is ModsAssetLibrary) {
					var modLib = cast(library, ModsAssetLibrary);
					@:privateAccess
					if (!modLib.__isCacheValid(modLib.cachedBytes, libThing.symbolName)) {
						refreshAlphabetXML(alphabetPath);
					}
				}
			}
		}

		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			lastWasSpace = character == " ";

			if (lastSprite != null)
				xPos = lastSprite.x + lastSprite.width - x;

			var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);
			if (isBold)
				letter.createBold(character);
			else
				letter.createLetter(character);

			// anim not found
			if (!letter.visible) 
				xPos += 40;
			add(letter);

			lastSprite = letter;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			// #if (haxe >= "4.0.0")
			// var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			// var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			// #else
			// var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			// var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			// #end

			// if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
			// 	// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			// {
			// 	if (lastSprite != null && !xPosResetted)
			// 	{
			// 		lastSprite.updateHitbox();
			// 		xPos += lastSprite.width + 3;
			// 		// if (isBold)
			// 		// xPos -= 80;
			// 	}
			// 	else
			// 	{
			// 		xPosResetted = false;
			// 	}

			// 	if (lastWasSpace)
			// 	{
			// 		xPos += 20;
			// 		lastWasSpace = false;
			// 	}
			// 	// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

			// 	// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
			// 	var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
			// 	letter.row = curRow;
			// 	if (isBold)
			// 	{
			// 		letter.createBold(splitWords[loopNum]);
			// 	}
			// 	else
			// 	{
			// 		if (isNumber)
			// 		{
			// 			letter.createNumber(splitWords[loopNum]);
			// 		}
			// 		else if (isSymbol)
			// 		{
			// 			letter.createSymbol(splitWords[loopNum]);
			// 		}
			// 		else
			// 		{
			// 			letter.createLetter(splitWords[loopNum]);
			// 		}

			// 		letter.x += 90;
			// 	}

			// 	if (FlxG.random.bool(40))
			// 	{
			// 		var daSound:String = "GF_";
			// 		FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
			// 	}

			// 	add(letter);

			// 	lastSprite = letter;
			// }

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = CoolUtil.fpsLerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);
			x = CoolUtil.fpsLerp(x, (targetY * 20) + 90, 0.16);
		}

		if (text != _finalText) {
			_finalText = text;
			for(e in members)
				e.destroy();
			@:privateAccess
			group.members = [];
			lastSprite = null;
			addText();
		}
	}
}

class AlphaCharacter extends FlxSprite
{
	@:dox(hide) @:noCompletion public static var __alphaPath:String = null;
	public static var boldAnims:Map<String, String> = [];
	public static var letterAnims:Map<String, String> = [];

	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		letter = letter.toUpperCase();
		if (boldAnims[letter] == null) {
			visible = false;
			return;
		} 
		animation.addByPrefix(letter, boldAnims[letter], 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		if (letterAnims[letter] == null) {
			visible = false;
			return;
		} 
		animation.addByPrefix(letter, letterAnims[letter], 24);
		animation.play(letter);
		updateHitbox();

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
