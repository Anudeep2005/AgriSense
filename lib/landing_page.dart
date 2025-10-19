import 'package:farm_guard_mvp/nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'services/homescreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/bg_1.jpeg',
      title: 'Smart Solutions',
      subtitle: 'Modern Farmers',
      description: 'Empowering farmers with smart tools for better yields and decisions',
      icon: Icons.agriculture,
      gradient: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    ),
    OnboardingPage(
      image: 'assets/bg_3.jpeg',
      title: 'Real-time Insights',
      subtitle: 'AI-Powered Predictions',
      description: 'IoT sensors and Gemini AI working together to provide instant weather analysis and actionable recommendations',
      icon: Icons.cloud_outlined,
      gradient: [Color(0xFF1976D2), Color(0xFF0D47A1)],
    ),
    OnboardingPage(
      image: 'assets/bg_2.jpeg',
      title: 'Complete Farm',
      subtitle: 'Management',
      description: 'Disease detection, knowledge hub, smart alerts, and comprehensive farm monitoring - all in one place',
      icon: Icons.spa_outlined,
      gradient: [Color(0xFF388E3C), Color(0xFF1B5E20)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _currentPage == _pages.length - 1
                ? _buildGetStartedButton()
                : _buildNavigationButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            page.image,
            fit: BoxFit.cover,
          ),
        ),    
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

      
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildLogo(),        
                const Spacer(),     
                _buildIconSection(page),     
                const SizedBox(height: 32),         
                _buildTitle(page),          
                const SizedBox(height: 16),    
                _buildDescription(page),         
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.eco,
            color: Color(0xFF2E7D32),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(text: 'Smart '),
                  TextSpan(
                    text: 'Solutions',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(text: 'Modern '),
                  TextSpan(
                    text: 'Farmers',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF66BB6A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconSection(OnboardingPage page) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: page.gradient[0].withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(OnboardingPage page) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          page.title,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          page.subtitle,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(OnboardingPage page) {
    return Text(
      page.description,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.9),
        height: 1.6,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SlideToAction(
      onSlideComplete: () {

        Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => const NavBar()),
        (route) => false, 
      );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        
        TextButton(
          onPressed: () {
            _pageController.animateToPage(
              _pages.length - 1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
          child: Text(
            'Skip',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF2E7D32),
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class SlideToAction extends StatefulWidget {
  final VoidCallback onSlideComplete;

  const SlideToAction({Key? key, required this.onSlideComplete}) : super(key: key);

  @override
  State<SlideToAction> createState() => _SlideToActionState();
}

class _SlideToActionState extends State<SlideToAction> {
  double _dragPosition = 0;
  double _maxDrag = 0;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxDrag = constraints.maxWidth - 72;

        return Container(
          width: double.infinity,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Container(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              Positioned(
                right: 24,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _dragPosition < _maxDrag * 0.7 ? 1.0 : 0.0,
                    child: Row(
                      children: [
                        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.9), size: 26),
                        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.6), size: 26),
                        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 26),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _dragPosition < _maxDrag * 0.5 ? 1.0 : 0.0,
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _isCompleted ? const Duration(milliseconds: 300) : Duration.zero,
                curve: Curves.easeOut,
                left: _dragPosition,
                top: 6,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, _maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition >= _maxDrag * 0.8) {
                      setState(() {
                        _dragPosition = _maxDrag;
                        _isCompleted = true;
                      });
                      Future.delayed(const Duration(milliseconds: 400), () {
                        widget.onSlideComplete();
                      });
                    } else {
                      setState(() {
                        _dragPosition = 0;
                      });
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}