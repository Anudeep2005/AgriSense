import 'package:flutter/material.dart';
import 'dart:ui';
import 'Cropcare.dart';
import 'prevention.dart';

class KnowledgeHubScreen extends StatelessWidget {
  
  final List<Map<String, dynamic>> crops = [
    {
      "name": "Tomato",
      "image": "assets/tomato.png",
      "careImage": "assets/tomato1.jpeg",
      "detailImage": "assets/tomato2.jpg",
      "scientificName": "Solanum lycopersicum",
      "duration": "100-120 days",
      "season": "Rabi & Summer",
      "soilType": "Well-drained loamy soil, pH 6-7",
      "climate": "Warm season, 20-25°C",
      "yield": "25-30 tons/ha",
      "stages": [
        {
          "title": "Nursery Preparation",
          "description":
              "Raise seedlings in a nursery with well-drained soil. Provide shade and keep soil moist until germination.",
        },
        {
          "title": "Transplanting",
          "description":
              "Move seedlings to the main field after 4-6 weeks when 4-6 true leaves appear. Water immediately after transplanting.",
        },
        {
          "title": "Vegetative Stage",
          "description":
              "The plant focuses on leaf and stem growth. Apply nitrogen-rich fertilizer and ensure staking for support.",
        },
        {
          "title": "Flowering Stage",
          "description":
              "Flowers begin to form. Maintain proper irrigation and apply phosphorus fertilizer for better flowering.",
        },
        {
          "title": "Fruit Development Stage",
          "description":
              "Pollinated flowers develop into fruits. Apply potassium fertilizer for healthy fruit growth.",
        },
        {
          "title": "Fruit Maturity Stage",
          "description":
              "Fruits change from green to red depending on variety. Sugar content and quality increase.",
        },
        {
          "title": "Harvesting",
          "description":
              "Harvest firm, fully-colored fruits carefully by hand. Avoid bruising during handling.",
        },
      ],
      "prevention": [
        "Use certified seeds",
        "Avoid waterlogging",
        "Install yellow sticky traps",
        "Balanced fertilizer application",
      ],
    },
    {
      "name": "Rice",
      "image": "assets/rice.png",
      "careImage": "assets/rice1.jpg",
      "detailImage": "assets/rice2.jpg",
      "scientificName": "Oryza sativa",
      "duration": "110–150 days",
      "season": "Kharif & Rabi",
      "soilType": "Clayey loam with good water retention",
      "climate": "Hot and humid, 20–35°C",
      "yield": "3–6 tons/ha",
      "stages": [
        {
          "title": "Seed Selection",
          "description":
              "Choose disease-free and high-yielding varieties to ensure good crop establishment.",
        },
        {
          "title": "Nursery Preparation",
          "description":
              "Prepare raised seedbeds, apply compost, and maintain proper irrigation for healthy seedlings.",
        },
        {
          "title": "Transplanting",
          "description":
              "Shift seedlings to the main field when they are 20–25 days old. Maintain proper spacing.",
        },
        {
          "title": "Tillering Stage",
          "description":
              "Multiple shoots develop from the base. Apply nitrogen fertilizer to encourage tillering.",
        },
        {
          "title": "Panicle Initiation",
          "description":
              "The plant starts forming panicles. Adequate phosphorus and potassium are required.",
        },
        {
          "title": "Grain Filling",
          "description":
              "Grains develop inside the panicle. Maintain proper irrigation and avoid moisture stress.",
        },
        {
          "title": "Harvesting",
          "description":
              "Harvest when grains are golden yellow and hard, usually 25-30 days after flowering.",
        },
      ],
      "prevention": [
        "Use resistant varieties",
        "Ensure proper water management",
        "Timely weeding",
        "Use bio-fertilizers",
      ],
    },
    {
      "name": "Wheat",
      "image": "assets/wheat.png",
      "careImage": "assets/wheat1.webp",
      "detailImage": "assets/wheat2.jpg",
      "scientificName": "Triticum aestivum",
      "duration": "120–150 days",
      "season": "Rabi",
      "soilType": "Well-drained loam or clay loam, pH 6–7.5",
      "climate": "Cool and dry, 15–25°C",
      "yield": "3–5 tons/ha",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Plough and level the field to ensure good soil tilth for seed germination.",
        },
        {
          "title": "Sowing",
          "description":
              "Use healthy seeds and sow at recommended spacing during the right season.",
        },
        {
          "title": "Crown Root Initiation",
          "description":
              "Roots start developing to support plant stability. Apply first irrigation here.",
        },
        {
          "title": "Tillering",
          "description":
              "Side shoots grow. Ensure sufficient nitrogen for maximum tiller production.",
        },
        {
          "title": "Booting",
          "description":
              "Head begins to form inside the leaf sheath. Irrigation is critical.",
        },
        {
          "title": "Grain Filling",
          "description":
              "Grains mature inside the ear. Maintain irrigation but avoid waterlogging.",
        },
        {
          "title": "Harvesting",
          "description":
              "Harvest when grains are hard and golden yellow. Ensure moisture is low for storage.",
        },
      ],
      "prevention": [
        "Seed treatment before sowing",
        "Avoid late sowing",
        "Monitor for rust disease",
        "Apply balanced NPK fertilizers",
      ],
    },
    {
      "name": "Cotton",
      "image": "assets/cotton.png",
      "careImage": "assets/cotton1.jpg",
      "detailImage": "assets/cotton2.jpg",
      "scientificName": "Gossypium hirsutum",
      "duration": "150–180 days",
      "season": "Kharif",
      "soilType": "Deep black soil or alluvial loam, pH 6–8",
      "climate": "Warm and dry, 25–35°C",
      "yield": "1.5–3 tons/ha (seed cotton)",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Deep ploughing followed by leveling ensures proper aeration and drainage.",
        },
        {
          "title": "Sowing",
          "description":
              "Use certified seeds and sow at proper spacing for healthy establishment.",
        },
        {
          "title": "Seedling Stage",
          "description":
              "Plants establish roots and leaves. Protect from early pests and maintain moisture.",
        },
        {
          "title": "Vegetative Growth",
          "description":
              "Rapid leaf and stem growth. Apply nitrogen fertilizers and irrigate regularly.",
        },
        {
          "title": "Flowering and Boll Formation",
          "description":
              "Flowers appear and bolls start forming. Potassium helps boll development.",
        },
        {
          "title": "Boll Maturity",
          "description":
              "Bolls mature and fibers develop. Avoid stress during this stage.",
        },
        {
          "title": "Harvesting",
          "description":
              "Pick cotton when bolls open fully. Multiple pickings are needed.",
        },
      ],
      "prevention": [
        "Use certified, delinted seeds",
        "Maintain proper spacing",
        "Monitor for bollworms and whiteflies",
        "Avoid excessive nitrogen fertilization",
        "Adopt crop rotation with legumes",
      ],
    },
    {
      "name": "Hotpepper",
      "image": "assets/hotpepper.png",
      "careImage": "assets/hotpepper1.jpg",
      "detailImage": "assets/hotpepper2.jpg",
      "scientificName": "Capsicum annuum",
      "duration": "120–150 days",
      "season": "Kharif & Rabi",
      "soilType": "Well-drained loamy soil, pH 6–7",
      "climate": "Warm and humid, 20–30°C",
      "yield": "10–15 tons/ha (green chili)",
      "stages": [
        {
          "title": "Nursery Preparation",
          "description":
              "Raise seedlings in shaded nursery beds. Maintain moisture for germination.",
        },
        {
          "title": "Transplanting",
          "description":
              "Shift seedlings to the field after 5-6 weeks. Maintain proper spacing.",
        },
        {
          "title": "Vegetative Stage",
          "description":
              "Plants produce leaves and branches. Apply nitrogen fertilizer.",
        },
        {
          "title": "Flowering Stage",
          "description":
              "Flowers form. Ensure proper irrigation for good fruit set.",
        },
        {
          "title": "Fruit Development",
          "description":
              "Fruits grow in size. Potassium fertilizer enhances quality.",
        },
        {
          "title": "Fruit Maturity",
          "description":
              "Fruits turn red or yellow depending on variety. Harvest begins soon.",
        },
        {
          "title": "Harvesting",
          "description":
              "Pick mature fruits carefully to avoid damaging branches.",
        },
      ],
      "prevention": [
        "Use disease-free seedlings",
        "Avoid waterlogging",
        "Install yellow sticky traps for whiteflies",
        "Apply mulch to retain soil moisture",
        "Rotate crops to avoid soil-borne diseases",
      ],
    },
    {
      "name": "Corn",
      "image": "assets/corn.png",
      "careImage": "assets/corn1.webp",
      "detailImage": "assets/corn2.jpg",
      "scientificName": "Zea mays",
      "duration": "90–120 days",
      "season": "Kharif & Rabi",
      "soilType": "Fertile loamy soil, pH 5.5–7",
      "climate": "Warm, 21–32°C with moderate rainfall",
      "yield": "4–8 tons/ha",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Plough and level the land. Apply organic manure before sowing.",
        },
        {
          "title": "Seed Sowing",
          "description":
              "Use treated seeds and sow at the right depth and spacing.",
        },
        {
          "title": "Germination and Seedling Stage",
          "description":
              "Seeds sprout and establish roots. Protect from soil pests.",
        },
        {
          "title": "Vegetative Growth (V6-V10)",
          "description":
              "Leaves develop rapidly. Apply nitrogen fertilizer and irrigate.",
        },
        {
          "title": "Tasseling and Silking",
          "description":
              "Male (tassel) and female (silk) flowers appear. Critical for pollination.",
        },
        {
          "title": "Grain Filling",
          "description":
              "Kernels develop and fill with starch. Ensure moisture availability.",
        },
        {
          "title": "Maturity and Harvesting",
          "description":
              "Cobs dry and kernels harden. Harvest at physiological maturity.",
        },
      ],
      "prevention": [
        "Treat seeds before sowing",
        "Maintain field sanitation",
        "Use pheromone traps for fall armyworm",
        "Avoid over-irrigation",
        "Rotate with non-cereal crops",
      ],
    },
    {
      "name": "Cabbage",
      "image": "assets/cabbage.png",
      "careImage": "assets/cabbage1.webp",
      "detailImage": "assets/cabbage2.jpg",
      "scientificName": "Brassica oleracea var. capitata",
      "duration": "90–120 days",
      "season": "Rabi",
      "soilType": "Fertile loamy soil, pH 6–6.5",
      "climate": "Cool and moist, 15–25°C",
      "yield": "25–35 tons/ha",
      "stages": [
        {
          "title": "Nursery Preparation",
          "description":
              "Raise seedlings in trays or beds. Maintain shade and moisture.",
        },
        {
          "title": "Transplanting",
          "description":
              "Transplant seedlings 4-5 weeks old with 4-6 true leaves.",
        },
        {
          "title": "Vegetative Growth",
          "description":
              "Leaves expand rapidly. Apply nitrogen fertilizer for healthy growth.",
        },
        {
          "title": "Head Formation",
          "description":
              "Inner leaves curl and form a compact head. Water regularly.",
        },
        {
          "title": "Maturity",
          "description": "Heads become firm and compact, ready for harvest.",
        },
        {
          "title": "Harvesting",
          "description":
              "Cut heads with a sharp knife, leaving outer leaves for protection.",
        },
      ],
      "prevention": [
        "Use pest-free nursery soil",
        "Maintain spacing to prevent disease",
        "Use netting against cabbage butterfly",
        "Avoid overhead irrigation",
        "Remove old crop debris after harvest",
      ],
    },
    {
      "name": "Cauliflower",
      "image": "assets/cauliflower.png",
      "careImage": "assets/cauliflower1.webp",
      "detailImage": "assets/cauliflower2.jpg",
      "scientificName": "Brassica oleracea var. botrytis",
      "duration": "90–130 days",
      "season": "Rabi",
      "soilType": "Well-drained loamy soil, pH 6–7",
      "climate": "Cool season, 15–25°C",
      "yield": "20–30 tons/ha",
      "stages": [
        {
          "title": "Seedbed Preparation",
          "description":
              "Prepare raised seedbeds with organic manure. Sow seeds thinly.",
        },
        {
          "title": "Transplanting",
          "description":
              "Transplant 4-5 week old seedlings with healthy roots.",
        },
        {
          "title": "Vegetative Growth",
          "description":
              "Plants develop large leaves. Apply nitrogen for faster growth.",
        },
        {
          "title": "Cupping and Curd Formation",
          "description":
              "Central curd (head) begins to form. Maintain even irrigation.",
        },
        {
          "title": "Maturity",
          "description": "Curds grow to full size, white and compact.",
        },
        {
          "title": "Harvesting",
          "description":
              "Cut curds carefully with a knife, keeping some wrapper leaves.",
        },
      ],
      "prevention": [
        "Use healthy seedlings",
        "Maintain proper drainage",
        "Apply balanced fertilizer (especially boron)",
        "Monitor for aphids and cutworms",
        "Destroy infected plant residues",
      ],
    },
    {
      "name": "Bengal Gram",
      "image": "assets/bengalgram.png",
      "careImage": "assets/bengalgram1.webp",
      "detailImage": "assets/bengalgram2.jpg",
      "scientificName": "Cicer arietinum",
      "duration": "100–120 days",
      "season": "Rabi",
      "soilType": "Well-drained loamy to sandy soil, pH 6–8",
      "climate": "Cool and dry, 20–25°C",
      "yield": "1.0–2.5 tons/ha",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Plough and level the field. Retain soil moisture for sowing.",
        },
        {
          "title": "Seed Treatment and Sowing",
          "description": "Treat seeds with fungicide and sow at proper depth.",
        },
        {
          "title": "Vegetative Growth",
          "description":
              "Plants grow leaves and branches. Apply phosphorus fertilizer.",
        },
        {
          "title": "Flowering",
          "description":
              "Small white flowers appear. Ensure adequate soil moisture.",
        },
        {
          "title": "Pod Formation",
          "description": "Pods form and fill with seeds. Avoid drought stress.",
        },
        {
          "title": "Maturity and Harvesting",
          "description":
              "Plants turn yellow and pods dry. Harvest and thresh carefully.",
        },
      ],
      "prevention": [
        "Treat seeds with fungicide before sowing",
        "Avoid waterlogging",
        "Use resistant varieties against wilt",
        "Follow crop rotation with cereals",
        "Monitor for pod borers regularly",
      ],
    },
    {
      "name": "Onion",
      "image": "assets/onion.png",
      "careImage": "assets/onion1.webp",
      "detailImage": "assets/onion2.jpg",
      "scientificName": "Allium cepa",
      "duration": "100–150 days",
      "season": "Rabi & Kharif",
      "soilType": "Light loam or sandy loam, pH 6–7",
      "climate": "Mild climate, 13–25°C",
      "yield": "20–25 tons/ha",
      "stages": [
        {
          "title": "Nursery Preparation",
          "description":
              "Raise seedlings in a nursery with well-drained sandy loam soil.",
        },
        {
          "title": "Transplanting",
          "description":
              "Shift 6-8 week old seedlings to the main field with proper spacing.",
        },
        {
          "title": "Bulb Formation",
          "description":
              "Plants start forming bulbs. Ensure regular irrigation.",
        },
        {
          "title": "Maturity",
          "description": "Leaves dry and bulbs mature underground.",
        },
        {
          "title": "Harvesting and Curing",
          "description":
              "Harvest bulbs, dry them in shade, and cure before storage.",
        },
      ],
      "prevention": [
        "Use well-drained soil",
        "Avoid overhead irrigation",
        "Apply neem-based pesticides against thrips",
        "Avoid excessive nitrogen fertilizer",
        "Cure bulbs properly to prevent rot",
      ],
    },
    {
      "name": "Potato",
      "image": "assets/potato.png",
      "careImage": "assets/potato1.jpg",
      "detailImage": "assets/potato2.jpg",
      "scientificName": "Solanum tuberosum",
      "duration": "90–120 days",
      "season": "Rabi & Autumn",
      "soilType": "Well-drained sandy loam, pH 5.5–6.5",
      "climate": "Cool, 15–20°C",
      "yield": "25–30 tons/ha",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Prepare well-drained soil. Apply FYM before planting tubers.",
        },
        {
          "title": "Planting Seed Tubers",
          "description": "Plant healthy tubers at correct spacing and depth.",
        },
        {
          "title": "Vegetative Growth",
          "description":
              "Plants produce stems and leaves. Apply nitrogen fertilizer.",
        },
        {
          "title": "Tuber Initiation",
          "description":
              "Small tubers start forming underground. Maintain moisture.",
        },
        {
          "title": "Tuber Bulking",
          "description":
              "Tubers increase in size. Potassium fertilizer is important.",
        },
        {
          "title": "Maturity and Harvesting",
          "description":
              "Leaves yellow and die back. Harvest tubers carefully to avoid damage.",
        },
      ],
      "prevention": [
        "Use disease-free seed tubers",
        "Practice crop rotation",
        "Maintain proper hilling and irrigation",
        "Monitor for late blight and aphids",
        "Avoid over-irrigation near maturity",
      ],
    },
    {
      "name": "Sugarcane",
      "image": "assets/sugarcane.png",
      "careImage": "assets/sugarcane1.webp",
      "scientificName": "Saccharum officinarum",
      "detailImage": "assets/sugarcane2.jpg",
      "duration": "10–18 months",
      "season": "Annual (Kharif/Rabi planting)",
      "soilType": "Deep, well-drained loamy soil, pH 6–8",
      "climate": "Tropical to subtropical, 20–35°C",
      "yield": "60–100 tons/ha",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Plough deeply and apply organic manure. Level the field for irrigation.",
        },
        {
          "title": "Setts Planting",
          "description":
              "Plant healthy setts (stem cuttings) in furrows at correct spacing.",
        },
        {
          "title": "Germination and Tillering",
          "description":
              "Buds sprout and new shoots emerge. Maintain moisture for uniform growth.",
        },
        {
          "title": "Grand Growth Stage",
          "description":
              "Plants grow rapidly in height and girth. Apply nitrogen fertilizers.",
        },
        {
          "title": "Ripening",
          "description":
              "Sugar content accumulates in canes. Reduce irrigation at this stage.",
        },
        {
          "title": "Harvesting",
          "description":
              "Cut mature canes at ground level. Harvest at peak sugar content.",
        },
      ],
      "prevention": [
        "Use healthy, pest-free setts",
        "Control early shoot borer with traps",
        "Avoid water stagnation",
        "Apply balanced NPK fertilizer",
        "Clean fields after harvest to reduce pest carryover",
      ],
    },
    {
      "name": "Carrot",
      "image": "assets/carrot.png",
      "careImage": "assets/carrot1.jpg",
      "detailImage": "assets/carrot1.jpg",
      "scientificName": "Daucus carota",
      "duration": "70–80 days",
      "season": "Cool season (Winter)",
      "soilType": "Sandy loam, well-drained, pH 6.0–6.8",
      "climate": "Cool and moist climate, 16–21°C",
      "yield": "20–30 tons/ha",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Loosen the soil to a depth of 30 cm, remove stones and debris.",
        },
        {
          "title": "Sowing",
          "description":
              "Sow seeds thinly in rows 30 cm apart; keep soil moist for germination.",
        },
        {
          "title": "Thinning and Weeding",
          "description":
              "Thin seedlings to 5 cm spacing once 2-3 leaves appear; keep area weed-free.",
        },
        {
          "title": "Irrigation",
          "description":
              "Provide regular watering to keep soil moist but not waterlogged.",
        },
        {
          "title": "Harvesting",
          "description":
              "Harvest carrots when roots reach desired size, usually 70–80 days after sowing.",
        },
      ],
      "prevention": [
        "Use disease-free seeds.",
        "Avoid waterlogging to prevent root rot.",
        "Practice crop rotation to reduce pests.",
        "Monitor for carrot fly larvae.",
        "Apply balanced fertilizers to promote root growth.",
      ],
    },
    {
      "name": "Garlic",
      "image": "assets/garlic.webp",
      "careImage": "assets/garlic1.jpg",
      "detailImage": "assets/garlic1.jpg",
      "scientificName": "Allium sativum",
      "duration": "90–150 days",
      "season": "Cool season (Winter planting for summer harvest)",
      "soilType": "Well-drained loamy soil, rich in organic matter, pH 6.0–7.0",
      "climate": "Cool climate, 12–24°C",
      "yield": "10–15 tons/ha",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Prepare well-drained soil with organic compost; remove stones.",
        },
        {
          "title": "Planting",
          "description":
              "Plant cloves 5 cm deep and 15 cm apart, rows 30 cm apart.",
        },
        {
          "title": "Irrigation",
          "description":
              "Maintain soil moisture during bulb formation; reduce watering before harvest.",
        },
        {
          "title": "Weeding",
          "description":
              "Keep field weed-free to reduce competition for nutrients.",
        },
        {
          "title": "Harvesting",
          "description":
              "Harvest when leaves begin to yellow and dry, typically after 90–150 days.",
        },
      ],
      "prevention": [
        "Use disease-free cloves for planting.",
        "Avoid waterlogging to prevent bulb rot.",
        "Practice crop rotation to prevent soil-borne diseases.",
        "Control pests like onion thrips and nematodes.",
        "Ensure balanced fertilization to promote healthy bulb growth.",
      ],
    },
    {
      "name": "Pea",
      "image": "assets/pea.png",
      "careImage": "assets/pea1.jpg",
      "detailImage": "assets/pea1.jpg",
      "scientificName": "Pisum sativum",
      "duration": "90–120 days",
      "season": "Cool season (Rabi crop, sown in winter)",
      "soilType": "Well-drained loamy soil, rich in organic matter, pH 6.0–7.5",
      "climate": "Cool and humid climate, optimal temperature 10–25°C",
      "yield": "6–10 tons/ha (green pods)",
      "stages": [
        {
          "title": "Land Preparation",
          "description":
              "Prepare fine tilth soil by 2–3 ploughings; mix well-rotted compost or FYM before sowing.",
        },
        {
          "title": "Sowing",
          "description":
              "Sow seeds 3–5 cm deep with 30 cm row spacing and 10 cm plant spacing. Avoid waterlogging.",
        },
        {
          "title": "Irrigation",
          "description":
              "First irrigation after germination; subsequent irrigations at flowering and pod formation stages. Avoid overwatering.",
        },
        {
          "title": "Weeding",
          "description":
              "Keep the crop weed-free during early growth; perform one or two hand weedings or hoeing operations.",
        },
        {
          "title": "Harvesting",
          "description":
              "Harvest green pods when fully developed but still tender; for dry seeds, allow pods to mature on the plant.",
        },
      ],
      "prevention": [
        "Use certified and disease-free seeds.",
        "Treat seeds with fungicide before sowing to prevent root rot.",
        "Avoid waterlogging to reduce fungal infections.",
        "Rotate crops to prevent pest and disease buildup.",
        "Monitor and control aphids, powdery mildew, and rust disease.",
        "Provide proper spacing for air circulation and sunlight penetration.",
      ],
    },
  ];
 

  KnowledgeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

         
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Center(
                    child: Text(
                      "Knowledge Hub",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 600, 
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: crops.length,
                          itemBuilder: (context, index) {
                            final crop = crops[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CropDetailScreen(crop: crop),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: AssetImage(crop["image"]!),
                                    backgroundColor: Colors.white24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    crop["name"]!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CropDetailScreen extends StatelessWidget {
  final Map<String, dynamic> crop;

  const CropDetailScreen({required this.crop, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
       
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(crop["detailImage"]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 220),

               
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop["name"],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Scientific Name: ${crop["scientificName"]}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Duration: ${crop["duration"]}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Season: ${crop["season"]}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Soil Type: ${crop["soilType"]}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Climate: ${crop["climate"]}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Yield: ${crop["yield"]}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

             
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CropCareScreen(crop: crop),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.eco, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Crop Care",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

              
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PreventionScreen(crop: crop),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.health_and_safety,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Prevention Tips",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

        
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
