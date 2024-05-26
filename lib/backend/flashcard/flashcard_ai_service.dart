import 'dart:convert';
import 'dart:io';

import 'package:deck/backend/custom_exceptions/api_exception.dart';
import 'package:deck/backend/models/cardAi.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FlashcardAiService{

  // Method to send data to api gateway
  Future<Map<String, dynamic>> sendData({
    required String id,
    required String subject,
    required String topic,
    required String addDescription,
    required String pdfFileName,
    required int numberOfQuestions,
    bool isNewMessage = true,
    String threadID = "no_thread_id",
  }) async {
    // Define request body
    Map<String, dynamic> requestBody = {
      'subject': subject,
      'topic': topic,
      'numberOfQuestions': numberOfQuestions,
      'pdfFileName': pdfFileName,
      'addDescription': addDescription,
      'isNewMessage': isNewMessage,
      'threadID': threadID,
    };

    // Make the API call
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/message/$id'), //API endpoint
      body: jsonEncode(requestBody),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON data
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      // If the server did not return a 200 OK response, throw an exception
      print(response.statusCode);
      switch (response.statusCode) {
        case 418:
          throw IncompleteRequestBodyException('Incomplete request body: ${response.body}');
        case 420:
          throw NumberOfCardsException('Unknown number of cards: ${response.body}');
        case 421:
          throw ForbiddenException('Forbidden: ${response.body}');
        case 404:
          throw NotFoundException('Not found: ${response.body}');
        case 500:
          throw InternalServerErrorException('Internal server error: ${response.body}');
        case 418:
          throw ApiException(418, 'I\'m a teapot: ${response.body}'); // Example for status code 418
        default:
          throw ApiException(response.statusCode, 'Error: ${response.body}');
      }
    }
  }
  //===========================================================================================

  Future<List<Cardai>> fetchData({
    required String id,
    required String threadID,
    required String runID,
  }) async {

    // Make the API call
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/response/$id?thread_id=$threadID&run_id=$runID'), //API endpoint
    );

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON data

      var jsonData = jsonDecode(response.body) as List;
      //var jsonDataQues = jsonDecode(jsonData)["question"] as List;
      print(jsonData);

      List<dynamic> questionsList = jsonData[0]['questions'];
      List<Cardai> flashCards = [];
      for (var questionAnswerPair in questionsList) {
        String question = questionAnswerPair['question'];
        String answer = questionAnswerPair['answer'];
        Cardai flashcard = new Cardai(question: question, answer: answer);
        flashCards.add(flashcard);
        // Use question and answer as needed
      }
      //List<Flashcard> flashCards = jsonData.map((flashObj) => Flashcard.fromJson(flashObj)).toList();

      return flashCards;
    } else {

      print(response.statusCode);

      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }
}