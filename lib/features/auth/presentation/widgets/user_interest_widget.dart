import 'package:coffeenity/core/common_widgets/custom_app_button.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../config/colors/app_colors.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/utils/app_prompts.dart';

class UserInterestWidget extends StatefulWidget {
  const UserInterestWidget({
    super.key,
    required this.onSelect,
    required this.selectedCoffees,
    required this.selectedCoffeeShops,
    required this.onCoffeeShopSelect,
  });

  final ValueChanged<String> onSelect;
  final List<String> selectedCoffees;
  final List<String> selectedCoffeeShops;
  final ValueChanged<String> onCoffeeShopSelect;

  @override
  State<UserInterestWidget> createState() => _UserInterestWidgetState();
}

class _UserInterestWidgetState extends State<UserInterestWidget> with TickerProviderStateMixin {
  late final List<AnimationController> _animationControllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Speech to text variables
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastProcessedText = ''; // Track last processed text to avoid duplicates
  final Set<String> _alreadyProcessed = {}; // Track already processed words/phrases

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();
    setState(() {});
  }

  void _initializeAnimations() {
    const int baseDuration = 500;
    const int staggerDelay = 100;
    const int totalFields = 4; // title + coffee title + shop title + voice section

    _animationControllers = List.generate(
      totalFields,
      (index) => AnimationController(
        duration: Duration(milliseconds: baseDuration + (index * staggerDelay)),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers
        .map(
          (controller) =>
              Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    _slideAnimations = _animationControllers
        .map(
          (controller) => Tween<Offset>(
            begin: const Offset(0.0, 0.9),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    // Pulse animation for voice input button border
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Start animations
    for (final controller in _animationControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _pulseController.dispose();
    _stopListening();
    super.dispose();
  }

  void _startListening() async {
    if (!_speech.isAvailable) {
      AppPrompts.showError(message: 'Speech recognition is not available');
      return;
    }

    setState(() {
      _isListening = true;
      _lastProcessedText = '';
      _alreadyProcessed.clear();
    });

    _pulseController.repeat();

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          // Process final result
          _processSpeech(result.recognizedWords, isFinal: true);
        } else {
          // Process partial results for real-time updates
          _processSpeech(result.recognizedWords, isFinal: false);
        }
      },
      listenFor: Duration(seconds: 30),
      listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: true),
    );
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      _pulseController.stop();
      _pulseController.value = 0.0;
      _alreadyProcessed.clear();
    }
  }

  void _toggleVoiceInput() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _processSpeech(String speech, {bool isFinal = false}) {
    // Only process new words
    if (speech.isEmpty || speech == _lastProcessedText) return;
    
    final newText = speech.substring(_lastProcessedText.length).toLowerCase().trim();
    if (newText.isEmpty) return;

    _lastProcessedText = speech;

    // Split into words and phrases
    final words = newText.toLowerCase().split(RegExp(r'\s+'));

    // Also check for multi-word phrases by looking at the entire new text
    _checkForMatchesInText(newText);

    // Check individual words
    for (final word in words) {
      if (word.length > 2) {
        // Only process words with more than 2 characters
        _checkWordForMatches(word);
      }
    }

    // If this is final result, also check the entire speech again
    if (isFinal) {
      _checkForMatchesInText(speech.toLowerCase());
    }
  }

  void _checkForMatchesInText(String text) {
    // Process coffee types
    for (final coffee in Coffee.coffeeList) {
      final coffeeName = coffee.name.toLowerCase();
      // Check if coffee name is in the text
      if (_containsWord(text, coffeeName) && !_alreadyProcessed.contains(coffeeName)) {
        _processCoffeeSelection(coffee.name);
        _alreadyProcessed.add(coffeeName);
      }
    }

    // Process coffee shop types
    for (final shop in Coffee.coffeeShopList) {
      final shopName = shop.name.toLowerCase();
      if (_containsWord(text, shopName) && !_alreadyProcessed.contains(shopName)) {
        _processShopSelection(shop.name);
        _alreadyProcessed.add(shopName);
      }
    }

    // Process synonyms
    _processSynonyms(text);
  }

  void _checkWordForMatches(String word) {
    // Check coffee types
    for (final coffee in Coffee.coffeeList) {
      final coffeeName = coffee.name.toLowerCase();
      if (_isMatch(word, coffeeName) && !_alreadyProcessed.contains(coffeeName)) {
        _processCoffeeSelection(coffee.name);
        _alreadyProcessed.add(coffeeName);
      }
    }

    // Check coffee shop types
    for (final shop in Coffee.coffeeShopList) {
      final shopName = shop.name.toLowerCase();
      if (_isMatch(word, shopName) && !_alreadyProcessed.contains(shopName)) {
        _processShopSelection(shop.name);
        _alreadyProcessed.add(shopName);
      }
    }
  }

  bool _containsWord(String text, String word) {
    // Check if word exists in text as a whole word
    final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }

  bool _isMatch(String spokenWord, String targetWord) {
    // Check for exact match or close match (handles minor mispronunciations)
    if (spokenWord == targetWord) return true;

    // Check if spoken word contains target word or vice versa
    if (spokenWord.contains(targetWord) || targetWord.contains(spokenWord)) {
      return spokenWord.length >= targetWord.length * 0.7; // At least 70% match in length
    }

    return false;
  }

  void _processCoffeeSelection(String coffeeName) {
    if (!widget.selectedCoffees.contains(coffeeName)) {
      widget.onSelect(coffeeName);
      // Provide haptic feedback for selection
      // HapticFeedback.selectionClick();
    }
  }

  void _processShopSelection(String shopName) {
    if (!widget.selectedCoffeeShops.contains(shopName)) {
      widget.onCoffeeShopSelect(shopName);
      // Provide haptic feedback for selection
      // HapticFeedback.selectionClick();
    }
  }

  void _processSynonyms(String speech) {
    // Coffee type synonyms
    final coffeeSynonyms = {
      'espresso': ['expresso', 'espress'],
      'cappuccino': ['cappucino', 'capuchino'],
      'latte': ['late', 'latté'],
      'americano': ['american'],
      'macchiato': ['machiato', 'macchiato'],
      'cold brew': ['coldbrew'],
      'flat white': ['flatwhite'],
      'french press': ['frenchpress'],
      'drip coffee': ['drip'],
      'iced coffee': ['ice coffee'],
      'all espresso coffee': ['espresso', 'expresso', 'espress'],
      'all cold coffee': ['coldbrew'],
      'all brewed coffee': ['drip', 'iced coffee'],
    };

    // Coffee shop type synonyms
    final shopSynonyms = {
      'modern': ['contemporary', 'sleek'],
      'cozy': ['comfortable', 'warm', 'intimate'],
      'unique': ['distinctive', 'original'],
      'traditional': ['classic', 'conventional'],
      'artisanal': ['handcrafted', 'craft'],
      'minimalist': ['minimal', 'simple'],
      'rustic': ['country', 'rural'],
      'industrial': ['factory', 'warehouse'],
      'vintage': ['retro', 'classic'],
      'urban': ['city', 'metropolitan'],
      'boutique': ['specialty', 'exclusive'],
      'scandinavian': ['scandi', 'nordic'],
      'bohemian': ['boho', 'eclectic'],
      'luxury': ['luxurious', 'premium'],
      'quaint': ['charming', 'picturesque'],
    };

    // Check coffee synonyms
    coffeeSynonyms.forEach((key, synonyms) {
      for (final synonym in synonyms) {
        if (_containsWord(speech, synonym) && !_alreadyProcessed.contains(key)) {
          _processCoffeeSelection(_capitalize(key));
          _alreadyProcessed.add(key);
          break;
        }
      }
      // Also check for the key itself
      if (_containsWord(speech, key) && !_alreadyProcessed.contains(key)) {
        _processCoffeeSelection(_capitalize(key));
        _alreadyProcessed.add(key);
      }
    });

    // Check shop synonyms
    shopSynonyms.forEach((key, synonyms) {
      for (final synonym in synonyms) {
        if (_containsWord(speech, synonym) && !_alreadyProcessed.contains(key)) {
          _processShopSelection(_capitalize(key));
          _alreadyProcessed.add(key);
          break;
        }
      }
      // Also check for the key itself
      if (_containsWord(speech, key) && !_alreadyProcessed.contains(key)) {
        _processShopSelection(_capitalize(key));
        _alreadyProcessed.add(key);
      }
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final coffees = Coffee.coffeeList;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        FadeTransition(
          opacity: _fadeAnimations[0],
          child: SlideTransition(
            position: _slideAnimations[0],
            child: Text("Select your favorite coffee", style: AppTypography.style24Bold),
          ),
        ),
        _buildAnimatedVoiceSection(),
        16.heightBox,
        FadeTransition(
          opacity: _fadeAnimations[1],
          child: SlideTransition(
            position: _slideAnimations[1],
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              direction: Axis.horizontal,
              children: coffees
                  .map(
                    (coffee) => GestureDetector(
                      onTap: () => widget.onSelect(coffee.name),
                      child: Chip(
                        label: Text(
                          coffee.name,
                          style: AppTypography.style14Regular.copyWith(color: AppColors.kAppBlack),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: widget.selectedCoffees.contains(coffee.name)
                            ? AppColors.kAppAmber
                            : AppColors.kAppWhite,
                        labelStyle: AppTypography.style14Regular,
                        avatar: widget.selectedCoffees.contains(coffee.name) ? const Icon(Icons.check) : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        100.heightBox,
      ],
    );
  }

  Widget _buildAnimatedVoiceSection() => FadeTransition(
    opacity: _fadeAnimations[3],
    child: SlideTransition(
      position: _slideAnimations[3],
      child: Container(
        padding: EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: AppColors.kAppWhite, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Text(
              "What's your favorite type of coffee, and what kind of coffee shop do you prefer (modern, cozy, unique, etc.)?",
              style: AppTypography.style16Regular.copyWith(color: AppColors.kAppBlack.withValues(alpha: 0.5)),
            ),
            16.heightBox,
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(30),
                    border: _isListening
                        ? Border.all(
                            color: AppColors.kAppDisabled.withValues(alpha: _pulseAnimation.value),
                            width: 2 + (_pulseAnimation.value * 2),
                          )
                        : null,
                  ),
                  child: child,
                );
              },
              child: CustomAppButton(
                text: _isListening ? "Stop Listening" : "Tell Us More...",
                onPressed: () => _toggleVoiceInput(),
                backgroundColor: _isListening ? AppColors.kAppCardColor : AppColors.kAppSecondary,
                icon: Icon(
                  _isListening ? CupertinoIcons.waveform : CupertinoIcons.mic,
                  color: AppColors.kAppWhite,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class Coffee {
  final String name;
  final String category;

  const Coffee(this.name, this.category);

  static List<Coffee> coffeeList = [
    Coffee('Affogato', 'Dessert/Espresso'),
    Coffee('Americano', 'Espresso-Based'),
    Coffee('Cappuccino', 'Espresso-Based'),
    Coffee('Cold Brew', 'Cold Coffee'),
    Coffee('Cortado', 'Espresso-Based'),
    Coffee('Dalgona', 'Whipped/Iced'),
    Coffee('Drip', 'Brewed Coffee'),
    Coffee('Espresso', 'Espresso-Based'),
    Coffee('Flat White', 'Espresso-Based'),
    Coffee('French Press', 'Brewed Coffee'),
    Coffee('Iced Coffee', 'Cold Coffee'),
    Coffee('Irish Coffee', 'Alcoholic'),
    Coffee('Latte', 'Espresso-Based'),
    Coffee('Macchiato', 'Espresso-Based'),
    Coffee('Mocha', 'Espresso-Based/Chocolate'),
    Coffee('Nitro Cold Brew', 'Cold Coffee'),
    Coffee('Turkish', 'Brewed Coffee'),
    Coffee('All Espresso Coffee', 'Espresso-Based'),
    Coffee('All Cold Coffee', 'Cold Coffee'),
    Coffee('All Brewed Coffee', 'Brewed Coffee'),
    Coffee('Select all', 'Select all'),
  ];

  static List<Coffee> coffeeShopList = [
    Coffee('Modern', 'Modern'),
    Coffee('Cozy', 'Cozy'),
    Coffee('Unique', 'Unique'),
    Coffee('Traditional', 'Traditional'),
    Coffee('Artisanal', 'Artisanal'),
    Coffee('Minimalist', 'Minimalist'),
    Coffee('Rustic', 'Rustic'),
    Coffee('Industrial', 'Industrial'),
    Coffee('Vintage', 'Vintage'),
    Coffee('Urban', 'Urban'),
    Coffee('Boutique', 'Boutique'),
    Coffee('Scandinavian', 'Scandinavian'),
    Coffee('Bohemian', 'Bohemian'),
    Coffee('Luxury', 'Luxury'),
    Coffee('Quaint', 'Quaint'),
    Coffee('Select all', 'Select all'),
  ];
}
