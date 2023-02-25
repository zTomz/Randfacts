import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:randfacts/models/fact.dart';
import 'package:randfacts/models/foreground_notifier.dart';
import 'package:randfacts/provider.dart';
import 'package:randfacts/widgets/bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulHookConsumerWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(factsProvider.notifier).loadFirstFacts();
    ref.read(backgroundProvider.notifier).init();
    ref.read(foregroundProvider.notifier).init();
  }

  @override
  void dispose() {
    ref.read(factsProvider.notifier).dispose();
    ref.read(backgroundProvider.notifier).dispose();
    ref.read(foregroundProvider.notifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Fact> facts = ref.watch(factsProvider);
    File? background = ref.watch(backgroundProvider);
    AppBrightness appBrightness = ref.watch(foregroundProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return const MyBottomSheet();
            },
          );
        },
        child: const Icon(Icons.person_rounded),
      ),
      body: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: background != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: FileImage(background),
                  fit: BoxFit.cover,
                ),
              )
            : const BoxDecoration(),
        child: PageView.builder(
          itemCount: facts.length,
          scrollDirection: Axis.vertical,
          onPageChanged: (value) {
            ref.read(factsProvider.notifier).loadMoreFacts();
          },
          itemBuilder: (context, index) => Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Text(
                    facts[index].text,
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ref
                          .read(foregroundProvider.notifier)
                          .getColorForBrightness(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned.fill(
                top: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        Share.share(
                          facts[index].text,
                          subject: "Look at this cool fact from Randfacts!",
                        );
                      },
                      icon: const Icon(Icons.share_rounded),
                      color: ref
                          .read(foregroundProvider.notifier)
                          .getColorForBrightness(context),
                      iconSize: 35,
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: PrettyQr(
                                data: facts[index].text,
                                size: 250,
                                roundEdges: true,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_rounded),
                      color: ref
                          .read(foregroundProvider.notifier)
                          .getColorForBrightness(context),
                      iconSize: 35,
                    ),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(factsProvider.notifier)
                            .toggleLikeFact(facts[index]);
                      },
                      icon: Icon(
                        facts[index].isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                      ),
                      color: facts[index].isLiked
                          ? Colors.red.shade500
                          : ref
                              .read(foregroundProvider.notifier)
                              .getColorForBrightness(context),
                      iconSize: 35,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
