import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _App(),
    ),
  );
}

class VideoData {
  final String name;
  final String videoAsset;

  VideoData({required this.name, required this.videoAsset});
}

class _App extends StatelessWidget {
  final List<VideoData> videos = [
    VideoData(name: 'Video 1', videoAsset: 'assets/check.mp4'),
    VideoData(name: 'Video 2', videoAsset: 'assets/check.mp4'),
    VideoData(name: 'Video 3', videoAsset: 'assets/check.mp4'),
    // Add more videos as needed
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: const ValueKey<String>('home_page'),
        appBar: AppBar(
          title: const Text(
            'Education and training',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 25,
            ),
          ),
          backgroundColor: Color(0xffe9dbff),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.insert_drive_file), text: 'Asset'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _VideoList(videos: videos),
          ],
        ),
      ),
    );
  }
}

class _VideoList extends StatefulWidget {
  final List<VideoData> videos;

  const _VideoList({Key? key, required this.videos}) : super(key: key);

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<_VideoList> {
  late List<VideoData> filteredVideos;

  @override
  void initState() {
    super.initState();
    filteredVideos = widget.videos;
  }

  void filterVideos(String searchTerm) {
    setState(() {
      filteredVideos = widget.videos
          .where((video) =>
              video.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Videos',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: filterVideos,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: (filteredVideos.length / 2).ceil(),
            itemBuilder: (context, index) {
              final startIndex = index * 2;
              final endIndex = (index + 1) * 2;
              final videosToShow = endIndex <= filteredVideos.length
                  ? 2
                  : filteredVideos.length - startIndex;

              return Column(
                children: [
                  Row(
                    children: List.generate(
                      videosToShow,
                      (innerIndex) {
                        final videoIndex = startIndex + innerIndex;
                        return Expanded(
                          child: _VideoListItem(
                            videoData: filteredVideos[videoIndex],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0), // Add a gap between video rows
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VideoListItem extends StatelessWidget {
  final VideoData videoData;

  const _VideoListItem({Key? key, required this.videoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _PlayerVideoAndPopPage(videoData: videoData),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              videoData.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _ButterFlyAssetVideo(videoAsset: videoData.videoAsset),
          // Add additional content below the video as needed
        ],
      ),
    );
  }
}

class _ButterFlyAssetVideo extends StatefulWidget {
  final String videoAsset;

  const _ButterFlyAssetVideo({Key? key, required this.videoAsset})
      : super(key: key);

  @override
  _ButterFlyAssetVideoState createState() => _ButterFlyAssetVideoState();
}

class _ButterFlyAssetVideoState extends State<_ButterFlyAssetVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset);

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          _ControlsOverlay(controller: _controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

class _PlayerVideoAndPopPage extends StatefulWidget {
  final VideoData videoData;

  const _PlayerVideoAndPopPage({Key? key, required this.videoData})
      : super(key: key);

  @override
  _PlayerVideoAndPopPageState createState() => _PlayerVideoAndPopPageState();
}

class _PlayerVideoAndPopPageState extends State<_PlayerVideoAndPopPage> {
  late VideoPlayerController _videoPlayerController;
  bool startedPlaying = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController =
        VideoPlayerController.asset(widget.videoData.videoAsset);
    _videoPlayerController.addListener(() {
      if (startedPlaying && !_videoPlayerController.value.isPlaying) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    startedPlaying = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder<bool>(
          future: started(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data ?? false) {
              return AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              );
            } else {
              return const Text('waiting for video to load');
            }
          },
        ),
      ),
    );
  }
}