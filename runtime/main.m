//
//  main.m
//  runtime
//
//  Created by oahgnehzoul on 16/8/4.
//  Copyright © 2016年 llzzzhh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "CustomClass.h"
#import "People.h"
#import "People+Associated.h"
#import "Bird.h"

void sayFunction(id self, SEL _cmd, id some) {
    
    /**
     * Reads the value of an instance variable in an object.
     *
     * @param obj The object containing the instance variable whose value you want to read.
     * @param ivar The Ivar describing the instance variable whose value you want to read.
     *
     * @return The value of the instance variable specified by \e ivar, or \c nil if \e object is \c nil.
     *
     * @note \c object_getIvar is faster than \c object_getInstanceVariable if the Ivar
     *  for the instance variable is already known.
     */
//    object_getIvar(<#id obj#>, <#Ivar ivar#>)

    /**
     * Returns the \c Ivar for a specified instance variable of a given class.
     *
     * @param cls The class whose instance variable you wish to obtain.
     * @param name The name of the instance variable definition to obtain.
     *
     * @return A pointer to an \c Ivar data structure containing information about
     *  the instance variable specified by \e name.
     */
//    class_getInstanceVariable(<#__unsafe_unretained Class cls#>, <#const char *name#>)
    NSLog(@"%@岁的%@说:%@",object_getIvar(self, class_getInstanceVariable([self class], "_age")),[self valueForKey:@"name"],some);
}

int main(int argc, const char * argv[]) {

    
//    ===============================================================
    
//    动态常见一个类，并创建成员变量和方法，最后赋值成员变量并发送消息(https://www.ianisme.com/ios/2019.html)
    
    //1. 动态创建一个继承自 NSObject 的 Person对象
//    objc_allocateClassPair(<#__unsafe_unretained Class superclass#>, <#const char *name#>, <#size_t extraBytes#>)
    Class Person = objc_allocateClassPair([NSObject class], "Person", 0);
    
    
    /**
     * Adds a new instance variable to a class.
     *
     * @return YES if the instance variable was added successfully, otherwise NO
     *         (for example, the class already contains an instance variable with that name).
     *
     * @note This function may only be called after objc_allocateClassPair and before objc_registerClassPair.
     *       Adding an instance variable to an existing class is not supported.
     * @note The class must not be a metaclass. Adding an instance variable to a metaclass is not supported.
     * @note The instance variable's minimum alignment in bytes is 1<<align. The minimum alignment of an instance
     *       variable depends on the ivar's type and the machine architecture.
     *       For variables of any pointer type, pass log2(sizeof(pointer_type)).
     */

    //2. 给 Person 类添加 NSString *_name 的成员变量
//    class_addIvar(<#__unsafe_unretained Class cls#>, <#const char *name#>, <#size_t size#>, <#uint8_t alignment#>, <#const char *types#>)
    class_addIvar(Person, "_name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    
    //3. 添加 int _age 变量
    class_addIvar(Person, "_age", sizeof(int), log2(sizeof(int)), @encode(int));
    
    
    //4. 注册方法名为 say 的方法
//    sel_registerName(<#const char *str#>)
    SEL s = sel_registerName("say");
    //5. 为 Person 添加 say 方法
//    class_addMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>, <#IMP imp#>, <#const char *types#>)
    class_addMethod(Person, s, (IMP)sayFunction, "v@:@");
    
    //6. 注册该类
    objc_registerClassPair(Person);
    
    //7. 创建一个类的实例
    id personInstance = [[Person alloc] init];
    //8. KVC 动态改变 personInstance 中的实例变量
    [personInstance setValue:@"苍老师" forKey:@"name"];
    //9. 获取_age 对应的 Ivar
    Ivar ageIvar = class_getInstanceVariable(Person, "_age");
    //10.给_age 对应的 Ivar 赋值
    object_setIvar(personInstance, ageIvar, @18);
    //11.调用 s 方法选择器对应的方法
//    ((void (*)(id, SEL, id))objc_msgSend)(personInstance, s,@"大家好！");
    objc_msgSend(personInstance, s,@"大家好!");
    
    //12. 当 Person 类或者它的子类的实例还存在，不能调用 objc_disposeClassPair 方法，因此需要先销毁实例对象再销毁类
    personInstance = nil;
    //13. 销毁类
    objc_disposeClassPair(Person);
    
    
//    ==================================================================
    
    
    // 获取所有对象的属性名称和属性值；实例变量和变量值；对象方法名和方法参数数量
    
    People *teacher = [[People alloc] init];
    teacher.name = @"苍井空";
    teacher.age = 18;
    [teacher setValue:@"老师" forKey:@"occupation"];
    
    NSDictionary *propertyResultDic = [teacher allProperties];
    for (NSString *propertyName in propertyResultDic) {
        NSLog(@"propertyName:%@,propertyValue:%@",propertyName,propertyResultDic[propertyName]);
    }
    
    NSDictionary *ivarsResultDic = [teacher allIvars];
    for (NSString *ivarName in ivarsResultDic) {
        NSLog(@"IvarName:%@,ivarValue:%@",ivarName,ivarsResultDic[ivarName]);
    }
    
    NSDictionary *methodResultDic = [teacher allMethods];
    for (NSString *method in methodResultDic) {
        NSLog(@"methodName:%@,argumentsCount:%@",method,methodResultDic[method]);
    }
    
    
//  ==========================================================================
    
    
    teacher.associatedBust = @90;
    teacher.associatedCallBack = ^{
        NSLog(@"苍老师要写代码了");
    };
    
    teacher.associatedCallBack();
    
//    ==========================================================================
    
    
    
    [teacher sing];
    
    Bird *bird = [[Bird alloc] init];
    bird.name = @"小小鸟";
    objc_msgSend(bird, @selector(sing));
    
    objc_msgSend(teacher, @selector(dance));
//    ===========================================================================
    
    NSDictionary *dic = @{
                          @"name":@"苍井空",
                          @"age":@18
                          };
    
    People *cangTeacher = [[People alloc] initWithDictionary:dic];
    NSLog(@"热烈欢迎，%ld岁的%@来游玩",cangTeacher.age,cangTeacher.name);
    
    NSDictionary *convertedDic = [cangTeacher convertToDictionary];
    NSLog(@"convertedDic:%@",convertedDic);
    
    //获取 指定类 cls 的类名。
//    class_getName(<#__unsafe_unretained Class cls#>)
    const char *str = class_getName([CustomClass class]);
    NSLog(@"const char :%s",str);
    
    
//    objc_getClass(<#const char *name#>)
    // 返回实例所属的类,  返回类的元类

    //NSObject的元类 是自己。
    NSLog(@"metaClass of NSObject:%@",objc_getClass(class_getName([NSObject class])));
    
    // 获取一个类的元类
    NSLog(@"metaClass of CustomClass:%@",objc_getClass("CustomClass"));
    Class cls = objc_getMetaClass("CustomClass");
    NSLog(@"%@,%@,%@",cls,class_getSuperclass(cls),objc_getClass(class_getName(cls)));
    //判断一个类 cls 是否是元类
//    class_isMetaClass(<#__unsafe_unretained Class cls#>)
    NSLog(@"NSObject IsMetaClass:%@",(class_isMetaClass([NSObject class])) ? @"yes":@"no");
    
    //获取一个类的父类
//    class_getSuperclass(<#__unsafe_unretained Class cls#>)
    NSLog(@"superClass of NSObject %@",class_getSuperclass([NSObject class]));
    NSLog(@"superClass of Custom %@",class_getSuperclass([CustomClass class]));
    
    // 获取指定名字的实例变量
//    class_getInstanceVariable(<#__unsafe_unretained Class cls#>, <#const char *name#>)

    // 获取指定名字的类变量
//    class_getClassVariable(<#__unsafe_unretained Class cls#>, <#const char *name#>)
    
    //获取 指定名字 类方法 SEL
//    class_getClassMethod([CustomClass class], <#SEL name#>)
    
    //获取 指定名字 实例方法 SEL
//    class_getInstanceMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>)

//    method_exchangeImplementations(<#Method m1#>, <#Method m2#>)

    // 类是否响应指定的方法
//    class_respondsToSelector(<#__unsafe_unretained Class cls#>, <#SEL sel#>)
    
    // 类是否遵循指定的协议
//    class_conformsToProtocol(<#__unsafe_unretained Class cls#>, <#Protocol *protocol#>)
    
    // 获取类的属性
//    class_getProperty(<#__unsafe_unretained Class cls#>, <#const char *name#>)
    
    // 获取类的属性列表，需要自己管理内存 free
//    class_copyPropertyList(<#__unsafe_unretained Class cls#>, <#unsigned int *outCount#>)
    
    // 为类 添加方法
//    class_addMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>, <#IMP imp#>, <#const char *types#>)

    // 替代类的方法
//    class_replaceMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>, <#IMP imp#>, <#const char *types#>)
    
    //给 指定类 添加成员变量
//    This function may only be called after objc_allocateClassPair and before objc_registerClassPair.
//    *       Adding an instance variable to an existing class is not supported.
//    * @note The class must not be a metaclass. Adding an instance variable to a metaclass is not supported.
//    * @note The instance variable's minimum alignment in bytes is 1<<align. The minimum alignment of an instance
//    *       variable depends on the ivar's type and the machine architecture.
//    *       For variables of any pointer type, pass log2(sizeof(pointer_type)).

    //    class_addIvar(<#__unsafe_unretained Class cls#>, <#const char *name#>, <#size_t size#>, <#uint8_t alignment#>, <#const char *types#>)
    
    // 为类 添加 协议
//    class_addProtocol(<#__unsafe_unretained Class cls#>, <#Protocol *protocol#>)
    
    //为类添加属性
//    class_addProperty(<#__unsafe_unretained Class cls#>, <#const char *name#>, <#const objc_property_attribute_t *attributes#>, <#unsigned int attributeCount#>)

    // 替代类的属性
//    class_replaceProperty(<#__unsafe_unretained Class cls#>, <#const char *name#>, <#const objc_property_attribute_t *attributes#>, <#unsigned int attributeCount#>)

    // 创建类和元类
//    objc_allocateClassPair(<#__unsafe_unretained Class superclass#>, <#const char *name#>, <#size_t extraBytes#>)

    // 注册类到 runtime
//    objc_registerClassPair(<#__unsafe_unretained Class cls#>)

    // 销毁类和对应的元类
//    objc_disposeClassPair(<#__unsafe_unretained Class cls#>)
    method_exchangeImplementations(class_getInstanceMethod([CustomClass class], @selector(run)), class_getInstanceMethod([CustomClass class], @selector(study)));
    


    CustomClass *c = [CustomClass new];
    [c run];
    [c study];
    
//    objc_msgSend(<#id self#>, <#SEL op, ...#>)
    
    // objc_msgSend 函数调用过程\
    一、检测 selector 是不是要忽略的\
    二、检测 target 是不是 nil，nil 则忽略\
    三、1.调用实例方法，首先在自身 isa 指向的类的 methodLists 中寻找方法，\
    找不到则通过 class 的 super_class 指针找到父类，寻找父类的 methodLists，找不到就向上一级，直到根 class\
        2.当调用类方法时，通过自己的 isa 指针找到 metaClass，从其中的 methodList 中寻找方法，找不到就通过 metaClass 的\
    superClass,找到父类的 metaClass，找不到就一直 superClass,直到 跟 metaClass\
    四、前三都找不到 就进入动态方法解析      \
                            ||         \
                            ||         \
    //消息动态解析            \/         \
    1.通过 resolveInstanceMethod 方法决定是否动态添加方法，yes 则通过 class_addMethod动态添加方法，no则进入下一步\
    2.进入 forwardingTargetForSelector 方法，用于指定备选对象响应这个 sel,不能指定为 self。如果返回对象就会调用对象的方法；返回 nil 进入下一步\
    3.通过 methodSignatureForSelector 方法签名，返回 nil 则消息无法处理，返回 methodSignature 则进入下一步\
    4.调用 forwardInvocation 方法，我们可以通过 anInvocation 对象做很多处理，例如修改实现方法、修改响应对象。方法调用成功则结束；如果失败就会进入 doesNotRecognizeSelector，如果我们没有实现这个方法，就会 crash\
    
    
//    objc_msgSend_stret(\, <#SEL op, ...#>)
    
    // 发消息给父类的实例
//    objc_msgSendSuper(<#struct objc_super *super#>, <#SEL op, ...#>)
    
    objc_msgSend(c, @selector(run));
//    objc_msgSend(<#id self#>, <#SEL op, ...#>) \
    根据方法编号SEL找到映射表中对应的IMP，然后实现方法调用
    objc_msgSend([CustomClass class], @selector(eat));
    
    c.age = 10;
    NSLog(@"%lu",c.age);
    
    unsigned int outCount = 0;
    //获取某个类的所有属性，outCount返回成员变量个数
    Ivar *ivars = class_copyIvarList([CustomClass class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        const char *name = ivar_getName(ivars[i]);
        const char *type = ivar_getTypeEncoding(ivars[i]);
        NSLog(@"name:%s,type:%s",name,type);
    }
    free(ivars);
    
    
    
    return 0;
}

