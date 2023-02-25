import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:randfacts/models/fact.dart';
import 'package:randfacts/models/foreground_notifier.dart';
import 'package:randfacts/provider.dart';
import 'package:share_plus/share_plus.dart';

class MyBottomSheet extends HookConsumerWidget {
  const MyBottomSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedFacts = useState(
      ref.read(factsProvider.notifier).getLikedFacts(),
    );

    final backgroundImages = ref.read(backgroundProvider.notifier).images;
    final appBrightness = ref.watch(foregroundProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      child: ListView(
        children: [
          Text(
            "Liked facts",
            style: GoogleFonts.openSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: likedFacts.value.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () => Share.share(
                  likedFacts.value[index].text,
                  subject: "Look at this cool fact from Randfacts!",
                ),
                title: Text(
                  likedFacts.value[index].text,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    ref
                        .read(factsProvider.notifier)
                        .toggleLikeFact(likedFacts.value[index]);

                    likedFacts.value = [
                      for (Fact myFact in likedFacts.value)
                        if (myFact.uuid == likedFacts.value[index].uuid)
                          Fact(
                            text: likedFacts.value[index].text,
                            isLiked: !likedFacts.value[index].isLiked,
                            uuid: myFact.uuid,
                          )
                        else
                          Fact(
                            text: myFact.text,
                            isLiked: myFact.isLiked,
                            uuid: myFact.uuid,
                          )
                    ];
                  },
                  icon: Icon(
                    likedFacts.value[index].isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                  ),
                  color: likedFacts.value[index].isLiked
                      ? Colors.red.shade500
                      : Colors.grey.shade800,
                  iconSize: 20,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                "Background",
                style: GoogleFonts.openSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ref.read(foregroundProvider.notifier).changeAppBrightness();
                },
                tooltip: "Change brightness",
                icon: Icon(_getIconForAppBrightness(appBrightness, context)),
                color: Colors.grey.shade800,
              ),
              IconButton(
                onPressed: () {
                  ref.read(backgroundProvider.notifier).deleteAllSavedImages();
                },
                tooltip: "Reset",
                icon: const Icon(
                  Icons.cancel_rounded,
                ),
                color: Colors.grey.shade800,
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: backgroundImages.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  ref
                      .read(backgroundProvider.notifier)
                      .changeImage(backgroundImages[index]);
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      backgroundImages[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  IconData _getIconForAppBrightness(
      AppBrightness appBrightness, BuildContext context) {
    if (appBrightness == AppBrightness.light) {
      return Icons.light_mode_rounded;
    }

    if (appBrightness == AppBrightness.dark) {
      return Icons.dark_mode_rounded;
    }

    return Icons.mode_standby_rounded;
  }
}
