import 'package:collection/collection.dart';

class Edge {
  final int targetNode; // The ID of the connected node
  final double distance; // The distance (weight) between the nodes
  final int lineId; // The ID of the line this edge belongs to

  Edge(this.targetNode, this.distance, this.lineId);

  @override
  String toString() {
    return "Edge(targetNode: $targetNode, distance: $distance, lineId: $lineId)";
  }
}

class Graph {
  final Map<int, List<Edge>> adjacencyList;

  Graph(this.adjacencyList);

  List<int> dijkstra(int startNode, int endNode) {
    final distances = <int, double>{};
    final previous = <int, int?>{};
    final lineTracker = <int, int?>{}; // Track the current line for each node
    final priorityQueue =
        PriorityQueue<int>((a, b) => distances[a]!.compareTo(distances[b]!));

    for (var node in adjacencyList.keys) {
      distances[node] = double.infinity;
      previous[node] = null;
      lineTracker[node] = null;
    }

    distances[startNode] = 0;
    priorityQueue.add(startNode);

    while (priorityQueue.isNotEmpty) {
      final currentNode = priorityQueue.removeFirst();

      print(
          "Processing Node $currentNode with distance ${distances[currentNode]}");

      if (currentNode == endNode) {
        // Reconstruct the path
        final path = <int>[];
        int? current = endNode;
        while (current != null) {
          path.add(current);
          current = previous[current];
        }
        return path.reversed.toList();
      }

      for (var edge in adjacencyList[currentNode] ?? []) {
        final double newDistance = distances[currentNode]! + edge.distance;

        print(
            "  Exploring Edge: $currentNode -> ${edge.targetNode} (distance: ${edge.distance}, lineId: ${edge.lineId})");

        if (newDistance < distances[edge.targetNode]!) {
          distances[edge.targetNode] = newDistance;
          previous[edge.targetNode] = currentNode;
          lineTracker[edge.targetNode] = edge.lineId; // Track the current line
          priorityQueue.add(edge.targetNode);

          print("    Updated Distance to ${edge.targetNode}: $newDistance");
        }
      }
    }

    return []; // No path found
  }
}

class PriorityQueue<T> {
  final List<T> _elements = [];
  final Comparator<T> _comparator;

  PriorityQueue(this._comparator);

  void add(T element) {
    _elements.add(element);
    _elements.sort(_comparator);
  }

  T removeFirst() {
    return _elements.removeAt(0);
  }

  bool get isNotEmpty => _elements.isNotEmpty;
}
