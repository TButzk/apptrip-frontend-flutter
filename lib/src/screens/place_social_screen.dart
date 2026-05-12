import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/social_content.dart';
import '../services/api_client.dart';
import '../services/social_service.dart';

class PlaceSocialScreen extends StatefulWidget {
  const PlaceSocialScreen({
    required this.place,
    required this.socialService,
    super.key,
  });

  final Place place;
  final SocialService socialService;

  @override
  State<PlaceSocialScreen> createState() => _PlaceSocialScreenState();
}

class _PlaceSocialScreenState extends State<PlaceSocialScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  late Future<List<TripPost>> _postsFuture;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _postsFuture = _loadPosts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ponto de parada')),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.name.isEmpty
                          ? 'Ponto ${widget.place.sequence ?? ''}'
                          : widget.place.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('${widget.place.latitude}, ${widget.place.longitude}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Novo registro',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Titulo',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Texto ou nota',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _createPost,
                      icon: _isSubmitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_comment),
                      label: const Text('Salvar registro'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<TripPost>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _MessageView(
                    icon: Icons.error_outline,
                    message: snapshot.error.toString(),
                    action: FilledButton.icon(
                      onPressed: () {
                        setState(() => _postsFuture = _loadPosts());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  );
                }

                final posts = snapshot.data ?? const <TripPost>[];
                if (posts.isEmpty) {
                  return const _MessageView(
                    icon: Icons.mode_comment_outlined,
                    message: 'Nenhum registro neste ponto.',
                  );
                }

                return Column(
                  children: [
                    for (final post in posts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PostSocialCard(
                          post: post,
                          socialService: widget.socialService,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<TripPost>> _loadPosts() {
    return widget.socialService.listPlacePosts(widget.place.id);
  }

  Future<void> _refreshPosts() async {
    setState(() => _postsFuture = _loadPosts());
    await _postsFuture;
  }

  Future<void> _createPost() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      setState(() => _errorMessage = 'Informe titulo e texto.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.socialService.createPost(
        CreatePostRequest(
          title: title,
          message: message,
          placeId: widget.place.id,
          date: DateTime.now(),
        ),
      );
      _titleController.clear();
      _messageController.clear();
      await _refreshPosts();
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (error) {
      setState(() => _errorMessage = 'Falha inesperada: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class PostSocialCard extends StatefulWidget {
  const PostSocialCard({
    required this.post,
    required this.socialService,
    super.key,
  });

  final TripPost post;
  final SocialService socialService;

  @override
  State<PostSocialCard> createState() => _PostSocialCardState();
}

class _PostSocialCardState extends State<PostSocialCard> {
  final _mediaNameController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  final _commentController = TextEditingController();

  late Future<List<TripMedia>> _mediaFuture;
  late Future<List<TripComment>> _commentsFuture;

  MediaType _selectedMediaType = MediaType.photo;
  bool _isAddingMedia = false;
  bool _isAddingComment = false;
  String? _mediaError;
  String? _commentError;

  @override
  void initState() {
    super.initState();
    _mediaFuture = _loadMedia();
    _commentsFuture = _loadComments();
  }

  @override
  void dispose() {
    _mediaNameController.dispose();
    _mediaUrlController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.post.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(widget.post.message),
            const Divider(height: 28),
            Text('Midias', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<TripMedia>>(
              future: _mediaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }

                final media = snapshot.data ?? const <TripMedia>[];
                if (media.isEmpty) {
                  return const Text('Nenhuma midia adicionada.');
                }

                return Column(
                  children: [
                    for (final item in media)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_iconForMedia(item.type)),
                        title: Text(
                          item.name.isEmpty ? item.type.label : item.name,
                        ),
                        subtitle: Text(item.url),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mediaNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome da midia',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mediaUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL da midia',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MediaType>(
              initialValue: _selectedMediaType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.perm_media),
              ),
              items: [
                for (final type in MediaType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: _isAddingMedia
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _selectedMediaType = value);
                      }
                    },
            ),
            if (_mediaError != null) ...[
              const SizedBox(height: 8),
              Text(
                _mediaError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isAddingMedia ? null : _addMedia,
              icon: const Icon(Icons.attach_file),
              label: const Text('Adicionar midia'),
            ),
            const Divider(height: 28),
            Text('Comentarios', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<TripComment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }

                final comments = snapshot.data ?? const <TripComment>[];
                if (comments.isEmpty) {
                  return const Text('Nenhum comentario.');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final comment in comments)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.comment_outlined),
                        title: Text(comment.message),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Novo comentario ou nota',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            if (_commentError != null) ...[
              const SizedBox(height: 8),
              Text(
                _commentError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isAddingComment ? null : _addComment,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar comentario'),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<TripMedia>> _loadMedia() {
    return widget.socialService.listPostMedia(widget.post.id);
  }

  Future<List<TripComment>> _loadComments() {
    return widget.socialService.listPostComments(widget.post.id);
  }

  Future<void> _addMedia() async {
    final name = _mediaNameController.text.trim();
    final url = _mediaUrlController.text.trim();

    if (name.isEmpty || url.isEmpty) {
      setState(() => _mediaError = 'Informe nome e URL da midia.');
      return;
    }

    setState(() {
      _isAddingMedia = true;
      _mediaError = null;
    });

    try {
      await widget.socialService.createMedia(
        widget.post.id,
        CreateMediaRequest(name: name, url: url, type: _selectedMediaType),
      );
      _mediaNameController.clear();
      _mediaUrlController.clear();
      setState(() => _mediaFuture = _loadMedia());
    } on ApiException catch (error) {
      setState(() => _mediaError = error.message);
    } catch (error) {
      setState(() => _mediaError = 'Falha inesperada: $error');
    } finally {
      if (mounted) {
        setState(() => _isAddingMedia = false);
      }
    }
  }

  Future<void> _addComment() async {
    final message = _commentController.text.trim();

    if (message.isEmpty) {
      setState(() => _commentError = 'Informe o comentario.');
      return;
    }

    setState(() {
      _isAddingComment = true;
      _commentError = null;
    });

    try {
      await widget.socialService.createComment(widget.post.id, message);
      _commentController.clear();
      setState(() => _commentsFuture = _loadComments());
    } on ApiException catch (error) {
      setState(() => _commentError = error.message);
    } catch (error) {
      setState(() => _commentError = 'Falha inesperada: $error');
    } finally {
      if (mounted) {
        setState(() => _isAddingComment = false);
      }
    }
  }

  IconData _iconForMedia(MediaType type) {
    return switch (type) {
      MediaType.photo => Icons.image_outlined,
      MediaType.video => Icons.videocam_outlined,
      MediaType.audio => Icons.audiotrack_outlined,
      MediaType.gif => Icons.gif_box_outlined,
    };
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
