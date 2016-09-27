import ceylon.test {
    ...
    }
    
"Run the module `org.someth2say.test`." 
shared void run(){
    // Write your code here and afterwards
    


}

test({`class Exception`})
shared void fooThrowingException() {
    throw Exception("unexpected exception");
}


