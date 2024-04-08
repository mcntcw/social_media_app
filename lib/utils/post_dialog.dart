import 'package:social_media_app/utils/image_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_repository/user_repository_library.dart';

// ignore: must_be_immutable
class PostDialog extends StatefulWidget {
  final MyUser user;
  final TextEditingController textController;
  final VoidCallback onCancel;
  final VoidCallback onAction;
  VoidCallback? onImageAction;
  final String actionText;
  String? imgFromPicker;
  Container? imageBody;
  bool? isLoading;

  PostDialog({
    Key? key,
    required this.textController,
    required this.onCancel,
    required this.onAction,
    required this.actionText,
    this.onImageAction,
    required this.user,
    this.imgFromPicker,
    this.imageBody,
    this.isLoading,
  }) : super(key: key);

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final ImageHandler imageHandler = ImageHandler();
  final ImagePicker picker = ImagePicker();
  String? image;
  String? choosenImage;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.onBackground,
                        image: DecorationImage(
                          image: widget.user.picture == null || widget.user.picture == ""
                              ? const AssetImage('assets/images/logo.png')
                              : NetworkImage(widget.user.picture.toString()) as ImageProvider<Object>,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.user.name.toLowerCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    widget.isLoading == true
                        ? Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          )
                        : Container()
                  ],
                ),
                widget.isLoading == true
                    ? Container()
                    : TextField(
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        controller: widget.textController,
                        maxLines: 8,
                        maxLength: 200,
                        decoration: InputDecoration(
                          hintText: "Enter text here...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ),
                widget.isLoading == true ? Container() : const SizedBox(height: 20),
                widget.isLoading == true
                    ? Container()
                    : GestureDetector(
                        onTap: () async {
                          widget.onImageAction!();
                        },
                        child: widget.imageBody,
                      ),
                widget.isLoading == true ? Container() : const SizedBox(height: 20),
                widget.isLoading == true
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.textController.clear();
                              widget.onCancel();
                            },
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onBackground,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              widget.onAction();
                              widget.textController.clear();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(60)),
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              child: Center(
                                child: Text(
                                  widget.actionText,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.background,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
