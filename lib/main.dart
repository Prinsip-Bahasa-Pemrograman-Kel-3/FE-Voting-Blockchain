// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const MyApp());
}

// Block class for the blockchain
class Block {
  int? index;
  String? voterId;
  String? candidate;
  String? previousHash;
  int? timestamp;
  String? hash;

  Block(this.index, this.voterId, this.candidate, this.previousHash)
      : timestamp = DateTime.now().millisecondsSinceEpoch {
    hash = calculateHash();
  }

  // Calculate the hash of the block
  String calculateHash() {
    var input = '$index$timestamp$voterId$candidate$previousHash';
    return sha256.convert(utf8.encode(input)).toString();
  }
}

// Blockchain class
class Blockchain {
  List<Block>? chain;
  Map<String, List<String>> candidateVotes; // Map to store votes per candidate
  Map<String, int> candidateVoteCount; // Map to store vote count per candidate

  // Initialize the blockchain with the genesis block
  Blockchain()
      : candidateVotes = {},
        candidateVoteCount = {} {
    chain = [createGenesisBlock()];
  }

  // Create the first block (genesis block)
  Block createGenesisBlock() {
    return Block(0, 'Genesis', 'None', '0');
  }

  // Get the latest block in the chain
  Block get latestBlock => chain!.last;

  // Add a new block to the blockchain
  void addBlock(String voterId, String candidate) {
    var newBlock = Block(chain!.length, voterId, candidate, latestBlock.hash);
    chain!.add(newBlock);

    // Update the candidateVotes map
    if (!candidateVotes.containsKey(candidate)) {
      candidateVotes[candidate] = [];
      candidateVoteCount[candidate] = 0;
    }
    candidateVotes[candidate]!.add(voterId);
    candidateVoteCount[candidate] = candidateVotes[candidate]!.length;
  }

  // Display the entire blockchain as a list of strings
  List<String> displayChain() {
    List<String> displayList = [];
    for (var block in chain!) {
      displayList.add('Block ${block.index}:\n'
          'Voter: ${block.voterId}\n'
          'Candidate: ${block.candidate}\n'
          'Hash: ${block.hash}\n'
          'Previous Hash: ${block.previousHash}\n'
          'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(block.timestamp!)}\n');
    }
    return displayList;
  }

  // Get the list of voters for a candidate
  List<String> getVotersForCandidate(String candidate) {
    return candidateVotes[candidate] ?? [];
  }

  // Get the count of votes for each candidate
  Map<String, int> getCandidateVoteCount() {
    return candidateVoteCount;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Blockchain blockchain = Blockchain();
  final TextEditingController voterController = TextEditingController();
  final TextEditingController candidateController = TextEditingController();

  List<String> blockchainDisplay = [];
  String candidateVotesDisplay = '';
  String candidateVoteCountDisplay = '';

  void addVote() {
    String voterId = voterController.text;
    String candidate = candidateController.text;

    if (voterId.isNotEmpty && candidate.isNotEmpty) {
      blockchain.addBlock(voterId, candidate);
      voterController.clear();
      candidateController.clear();
      setState(() {
        blockchainDisplay = blockchain.displayChain();
        candidateVotesDisplay = 'Votes per Candidate:\n'
            '${blockchain.getCandidateVoteCount().entries.map((entry) => '${entry.key}: ${entry.value} votes').join('\n')}';
        candidateVoteCountDisplay = 'Details:\n'
            '${blockchain.getCandidateVoteCount().entries.map((entry) => '${entry.key}: ${entry.value} votes').join('\n')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Voting Blockchain'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: voterController,
                decoration: const InputDecoration(labelText: 'Enter Voter ID'),
              ),
              TextField(
                controller: candidateController,
                decoration: const InputDecoration(labelText: 'Enter Candidate Name'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: addVote,
                child: const Text('Cast Vote'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: blockchainDisplay.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          blockchainDisplay[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(candidateVotesDisplay),
            ],
          ),
        ),
      ),
    );
  }
}
