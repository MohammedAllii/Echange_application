import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_simple_page/Views/HomeScreen.dart';
import '../Services/ApiClient.dart';

class AddImagesScreen extends StatefulWidget {
  final int productId;

  const AddImagesScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _AddImagesScreenState createState() => _AddImagesScreenState();
}

class _AddImagesScreenState extends State<AddImagesScreen> {
  List<File> _selectedImages = [];

  Future<void> _selectImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _uploadImagesAndFinish() async {
    try {
      if (_selectedImages.isNotEmpty) {
        for (File image in _selectedImages) {
          Map<String, dynamic> response =
              await ApiClient.uploadImage(widget.productId, image);

          // Check the response from the API
          if (response.containsKey('error')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${response['error']}'),
                duration: Duration(seconds: 2),
              ),
            );
            return; // Stop if any image upload fails
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Images added to your product successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Optionally, you can navigate to the HomeScreen or perform any other actions
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Select at least one image'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading images: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF545D68)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          " Step 2 : Ajouter Images",
          style: TextStyle(
            fontFamily: 'Varela',
            fontSize: 20.0,
            color: Color(0xFF545D68),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _selectedImages.isNotEmpty
                ? SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Image.file(
                                _selectedImages[index],
                                height: 200,
                                width: 200,
                              ),
                            ),
                            Positioned(
                              top: 8.0,
                              right: 8.0,
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _removeImage(index);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Placeholder(
                    fallbackHeight: 200.0,
                  ),
            SizedBox(height: 16.0),
            ElevatedButton(
  onPressed: _selectImages,
  style: ElevatedButton.styleFrom(
    textStyle: TextStyle(color: Colors.black),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/select.png',
        height: 64.0, // Adjust the height as needed
        width: 54.0,  // Adjust the width as needed
      ),
      SizedBox(width: 15.0), // Add spacing between the image and text
      Text('Select Images'),
    ],
  ),
),
            SizedBox(height: 16.0),
            ElevatedButton(
  onPressed: _uploadImagesAndFinish,
  style: ElevatedButton.styleFrom(
    primary: Color.fromARGB(255, 27, 199, 76),
    textStyle: TextStyle(color: Colors.white),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/ajout.png',
        height: 44.0, // Adjust the height as needed
        width: 45.0,  // Adjust the width as needed
      ),
      SizedBox(width: 20.0), // Add spacing between the image and text
      Text('Finish'),
    ],
  ),
),
          ],
        ),
      ),
    );
  }
}
