;********************* External and Utility functions *********************

declare i32 @printf(i8* noalias nocapture, ...) nounwind

;******************************* Foo class ********************************

%Foo = type { i32 }

define void @Foo_Create_Default(%Foo* %this) nounwind {
    %1 = getelementptr %Foo* %this, i32 0, i32 0
    store i32 0, i32* %1
    ret void
}

define i32 @Foo_GetLength(%Foo* %this) nounwind {
    %1 = getelementptr %Foo* %this, i32 0, i32 0
    %2 = load i32* %1
    ret i32 %2
}

define void @Foo_SetLength(%Foo* %this, i32 %value) nounwind {
    %1 = getelementptr %Foo* %this, i32 0, i32 0
    store i32 %value, i32* %1
    ret void
}

;********************************* Foo function ***************************

@.message1 = internal constant [30 x i8] c"Exception requested by caller\00"

define { i8*, i32 } @Bar(i1 %fail) nounwind {
    ; Allocate Foo instance
    %foo = alloca %Foo
    call void @Foo_Create_Default(%Foo* %foo)

    call void @Foo_SetLength(%Foo* %foo, i32 17)

    %ex_and_ret_val = alloca { i8*, i32 }
    %ex = getelementptr { i8*, i32 }* %ex_and_ret_val, i32 0, i32 0
    %ret_val = getelementptr { i8*, i32 }* %ex_and_ret_val, i32 0, i32 1
    ; if (fail)
    %1 = icmp eq i1 %fail, true
    br i1 %1, label %.if_begin, label %.if_close

.if_begin:
    ; throw "Exception requested by caller"
    %2 = getelementptr [30 x i8]* @.message1, i32 0, i32 0
    store i8* %2, i8** %ex
    %3 = load { i8*, i32 }* %ex_and_ret_val
    ret { i8*, i32 } %3

.if_close:
    ; foo.SetLength(24)
    call void @Foo_SetLength(%Foo* %foo, i32 24)
    %4 = call i32 @Foo_GetLength(%Foo* %foo)
    store i32 %4, i32* %ret_val
    store i8* null, i8** %ex, align 8
    %5 = load { i8*, i32 }* %ex_and_ret_val
    ret { i8*, i32 } %5
}


;********************************* Main program ***************************

@.message2 = internal constant [11 x i8] c"Error: %s\0A\00"
@.message3 = internal constant [44 x i8] c"Internal error: Unhandled exception detectd\00"

define i32 @main(i32 %argc, i8** %argv) nounwind {
.try_block:
    ; fail = (argc >= 2)
    %fail = icmp uge i32 %argc, 2

    ; Function call.
    %0 = alloca i32
    %1 = alloca i32
    %2 = call { i8*, i32 } @Bar(i1 %fail)
    %3 = extractvalue { i8*, i32 } %2, 0
    %4 = icmp ne i8* %3, null
    br i1 %4, label %.catch_block, label %.exit

.catch_block:
    %5 = getelementptr [11 x i8]* @.message2, i32 0, i32 0
    %6 = call i32 (i8*, ...)* @printf(i8* %5, i8* %3)
    br label %.exit

.exit:
    %result = phi i32 [ 0, %.try_block ], [ 1, %.catch_block ]
    ret i32 %result
}