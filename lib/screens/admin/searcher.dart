class Searcher {
  List<Map> _users;
  String firstQuery;
  String lastQuery;

  Searcher(users, firstName, lastName) {
    this._users = users;
    this.firstQuery = firstName;
    this.lastQuery = lastName;
  }

  //returns a MaxList containing most relevant search results at the top of list
  MaxList search() {
    //relevance is based on the longest common substring shared between the query and values
    MaxList relevanceList = new MaxList();
    for (int i = 0; i < _users.length; i++) {
      Map firstNameRelevance = {'Points': 0};
      Map lastNameRelevance = {'Points': 0};
      if (firstQuery != "") {
        firstNameRelevance = findLongestCommonSubstring(
            firstQuery.toLowerCase(), _users[i]['first_name'].toLowerCase());
      }
      if (lastQuery != "") {
        lastNameRelevance = findLongestCommonSubstring(
            lastQuery.toLowerCase(), _users[i]['last_name'].toLowerCase());
      }

      Map fullNameRelevance = {
        'info': _users[i],
        'Points': firstNameRelevance['Points'] + lastNameRelevance['Points'],
      };
      relevanceList.append(Node(fullNameRelevance));
    }
    return relevanceList;
  }

  Map findLongestCommonSubstring(a, b) {
    int total = 0;
    int tempCounter = 0;
    List tempList = [];
    List finalList = [];
    for (int i = 0; i < a.length; i++) {
      tempList = [];
      tempCounter = 0;

      for (int j = 0; j < b.length; j++) {
        if (a[i] == b[j]) {
          tempList.add(a[i]);
          i++;
          tempCounter++;
          if (tempCounter > total) {
            total = tempCounter;
            finalList = tempList;
          }
          if (i == a.length) {
            break;
          }
        } else {
          tempCounter = 0;
          tempList = [];
        }
      }
    }
    return {'Substring': tempList, 'Points': total};
  }
}

class MaxList {
  Node head; //this should be the maximum node
  int _size;

  MaxList() {
    head = null;
    _size = 0;
  }

  void printNodes() {
    Node current = head;
    while (current != null) {
      print(current.element['info']['first_name'] +
          " " +
          current.element['Points'].toString());
      current = current.next;
      print("-");
    }
    print("------------------");
  }

  int getSize() {
    return _size;
  }

  void append(Node nextNode) {
    //if our MaxList is empty
    if (head == null) {
      head = nextNode;
    }
    //if nextNode is bigger than our head
    else if (head.element['Points'] <= nextNode.element['Points']) {
      head.previous = nextNode;
      nextNode.next = head;
      head = head.previous;
    }
    //traverse till we find a place to put our nextNode
    else {
      Node current = head;
      Node lastNode = head.previous;
      bool isPlaceFound = false;

      while (current != null && !isPlaceFound) {
        //if we reached a point where we can place nextNode
        if (nextNode.element['Points'] > current.element['Points']) {
          //create refrence of nodes that are directly left and to the right
          Node rightNode = current.previous.next;
          Node leftNode = current.previous;
          //start changing pointers
          current.previous.next = nextNode;
          nextNode.next = rightNode;
          nextNode.previous = leftNode;
          rightNode.previous = nextNode;

          isPlaceFound = true;
        } else {
          //iteration
          lastNode = current;
          current = current.next;
        }
      }
      //if nextNode was the minimum
      if (!isPlaceFound) {
        lastNode.next = nextNode;
        nextNode.previous = lastNode;
      }
    }
    _size++;
  }
}

class Node {
  Map element;
  Node next;
  Node previous;

  Node(Map element) {
    this.element = element;
    this.next = null;
    this.previous = null;
  }
}
