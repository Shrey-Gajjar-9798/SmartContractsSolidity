pragma solidity ^0.8.0;

contract MMS {

//----------------data---------------- 
address private faculty_address;
string[] public studentadded;
uint256 public totalstudents;

//key=exam_code and value=bool
mapping(string => bool) private isExamExist;
//key=exam_code and value=Exam
mapping(string => Exam) private exams;

//key=studenID and value=bool
mapping(string => bool) private isStudentExist;
//key=studenID and value=Student
mapping(string => Student) private students;
mapping(string => UpdateLog[]) public logofStudentid;

//key=studenID key=exam_code value=bool
mapping(string => mapping(string => bool)) private isMarksAssign;
//key=studenID key=exam_code value=uint256
mapping(string => mapping(string => uint256)) private studentsMarks;
//key=_studentID key=exam_code value=bool
mapping(string => mapping(string => bool)) private studentsExamResult;
//----------------models---------------- 
struct Exam {
    string exam_code;
    uint256 total_marks;
    uint256 require_marks; 
}

struct Student {
    string studenID;
}

struct UpdateLog{
    address name;
    string examcode;
    uint prevmarks;
    uint currentmarks;
}

//----------------constructor---------------- 
constructor() public {
     faculty_address = msg.sender; 
    }

//----------------modifiers----------------

//operation must done by faculty
modifier only_faculty {
    require(faculty_address == msg.sender , "Only faculty can use this");
    _;
}
//exam must exist
modifier exam_exist(string memory _exam_code) {
    require(isExamExist[_exam_code] , "Exam not exist!!");
    _;
}
//exam must not exist
modifier exam_not_exist(string memory _exam_code) {
    require(!isExamExist[_exam_code] , "Exam already exist!!");
    _;
}
//student must exist
modifier student_exist(string memory _studentID) {
    require(isStudentExist[_studentID], "Student not exist!!");
    _;
}
//student must not exist
modifier student_not_exist(string memory _studentID) {
    require(!isStudentExist[_studentID], "Student already exist!!");
    _;
}
//marks must be match the constraints
modifier validate_marks(uint256 _total_marks,uint256 _require_marks) {
    require(_require_marks >= 0 && _require_marks <=_total_marks ,"Invalid marks"); 
    _; 
} //marks must not assigned 
modifier marks_not_assigned(string memory _studentID,string memory _exam_code) {
    require(!isMarksAssign[_studentID][_exam_code],"marks already assign");
    _; 
    } 

modifier validate_assigned_marks(string memory _exam_code,uint256 _assigned_marks) {
    require(_assigned_marks<=exams[_exam_code].total_marks,"Invalid marks"); 
    _; 
    }

//----------------functions---------------- 
function add_exam( string memory _exam_code, uint256 _total_marks, uint256 _require_marks) public 
    only_faculty exam_not_exist(_exam_code) validate_marks(_total_marks,_require_marks) { 
        isExamExist[_exam_code]=true;
        exams[_exam_code]=Exam(_exam_code,_total_marks,_require_marks); 
}

function add_students(
    string memory _studentID)
    public
    only_faculty
    student_not_exist(_studentID)
    {
isStudentExist[_studentID]=true; 
students[_studentID]=Student(_studentID); 
studentadded.push(_studentID);
totalstudents++;
}

function assign_marks(
    string memory _studentID,
    string memory _exam_code,
    uint256 _assigned_marks)
    public
    only_faculty
    student_exist(_studentID)
    exam_exist(_exam_code)
    marks_not_assigned(_studentID,_exam_code)
    validate_assigned_marks(_exam_code,_assigned_marks)
    {
        isMarksAssign[_studentID][_exam_code]=true;
        studentsMarks[_studentID][_exam_code]=_assigned_marks;
        updateStudentExamResult(_studentID,_exam_code,_assigned_marks);
    }

function updateStudentExamResult( string memory _studentID, string memory _exam_code, uint256 _assigned_marks) private {
     if(_assigned_marks < exams[_exam_code].require_marks) {
          studentsExamResult[_studentID][_exam_code]=false; 
        } 
    else{ studentsExamResult[_studentID][_exam_code]=true; 
    } 
}
address admin = 0x3b9bA781797b57872687Ce5d5219A1A4Bc0e85ea;
//add the fucnitonality for faculty to add the marks for specific exam
function updateMarks(string memory _studentID, string memory _exam_code, uint256 _assigned_marks) public{
        if(keccak256(abi.encodePacked(_assigned_marks)) != keccak256(abi.encodePacked(studentsMarks[_studentID][_exam_code]))){
            // require(msg.sender==admin,"Only Address 85ea can do the update changes");
            uint prvvalue = studentsMarks[_studentID][_exam_code];
            studentsMarks[_studentID][_exam_code] = _assigned_marks;
            logofStudentid[_studentID].push(UpdateLog(msg.sender,_exam_code,prvvalue,_assigned_marks));
            // getbypolicyno[_policyno].insname = _insname;
            // logofpolicyno[_policyno].push(UpdateLog(msg.sender,block.number,"Insurance name", prvvalue,_insname));
            // getbypolicyno[_policyno].totalupdates++;
            // emit Logdata(msg.sender);
        }
        else{
            revert("Transcation cancelled");
        }
}

event showDetails(
    string _studentID,
    string _exam_code,
    bool _isMarksAssign,
    uint256 _studentsMarks,
    bool studentsExamResult);

function getDetails(
    string memory _studentID,
    string memory _exam_code)
    public view
    only_faculty
    student_exist(_studentID)
    exam_exist(_exam_code)
    returns(string memory studentid, string memory examcode, bool studentMarks,uint256 obtainedmarks,bool Result) {
        return (_studentID,
                _exam_code,
                isMarksAssign[_studentID][_exam_code],
                studentsMarks[_studentID][_exam_code],
                studentsExamResult[_studentID][_exam_code]);
    }
}