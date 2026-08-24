## Giới thiệu bản thân

Tôi là một Software Developer thiên về Web Development: Java Spring Boot, ReactJS, TailwindCSS và Postgres.

## Đối tượng sử dụng

- Chỉ là app nội bộ cho tôi và bạn bè tôi dùng (những ai)
- Hiện tại thì chưa cần Publish lên Store
- Lượng người dùng không quá 10 người

## Bối cảnh

Hiện tại, trong quá trình học tiếng anh, tôi sử dụng table của Notion để ghi chép từ vựng. Mỗi Row từ vựng của tôi bao gồm

- Từ vựng
- Phiên âm (IPA)
- Loại từ (tính, động, danh, trạng)
- Level của từ (C1, C2,...)
- Usage (slang, informal, nói tục, formal,...)
- Nghĩa tiếng việt
- Ví dụ cho mỗi nghĩa.

## Vấn đề

1. Trong trường hợp tôi chép từ vựng khi nghe podcast hoặc xem video, thì tôi sẽ phải pause video lại để chép vì việc điền vào từng field của một từ vựng sẽ rất lâu, và khiến tôi mất tập trung.
2. Tôi phải tốn thời gian tra cứu từ điển.
3. Tôi không thể ghi phiên âm IPA được mà phải copy từ một từ điển online.
4. Thi thoảng thì từ điển không cho tôi biết level của từ vựng này là C1,C2, hay B1,B2, trong khi đây là thông tin rất cần thiết khi tôi muốn biết từ vựng này có thể dùng để thi Ielts được không.
5. Không có phần loại từ vựng và không có phần trang: Tất cả từ vựng mà tôi chép được trong Notion thì đều chỉ trong 1 table, và hiện tại thì table cũng đã rất dài, không thể nào tìm kiếm hay phân loại từ vựng được.
6. Mặc dù đã nhận thức được vấn đề 5. nhưng tôi lại không có động lực để sắp xếp lại hay thay đổi bảng của tôi, vì nó khá là tốn thời gian.
7. Tôi không biết từ vựng tôi sắp nhập đã được ghi trước đó hay chưa. Vì vây tôi thường phải ctrl F để check.

## Kỳ vọng

- Sẽ là một ứng dụng Mobile và Web App.
- Ứng dụng Note từ vựng chỉ cần khi từ vựng tiếng anh (mọi Field khác thì có thể sử dụng API của các dictionary, các field nào mà API không bổ sung được thì dùng AI).
- Sử dụng AI để tự phân loại từ vựng vào các Collection.
- Dùng các AI API free.
- Ứng dụng này không được tốt phí để sử dụng.
- Các API và AI thì cần wifi để sử dụng, nhưng việc lưu trữ từ vựng có thể hoàn toàn offline. Người dùng vẫn có thể vào sổ từ vựng và xem lại, tra cứu khi không có wifi.
- Đồng bộ dữ liệu mỗi tài khoản đối với Mobile và Web app. Ví dụ: Khi không mang laptop theo thì tôi có thể sử dụng Mobile App để ghi chép, và khi có laptop thì có thể lên Web app để coi lại (vì tôi thường dùng laptop khi ở nhà và mobile khi ra đường)
- Các chức năng nào AI gen được thì cũng phải tùy chỉnh được

# Các chức năng chính mà tôi mong muốn

1. Note từ vựng thông minh (như đã trình bày ở trên)
2. Quản lý Collection và từ vựng theo từng tài khoản User
3. Thông báo random 1 Từ vựng mỗi ngày trong các từ vựng đã ghi (để giúp tôi nhớ lại từ vựng cũ).
4. Người dùng có thể chọn tự điền các field hoặc dùng API dictionary hoặc AI. Và có thể sửa đổi những gì AI hoặc dictionary điền vào.
5. Các chức năng khác như statistics, ... hoặc các chức năng mà tôi không nghĩ đến nhưng sẽ hữu ích khi sử dụng.

## Techstack

- ReactJS cho Web
- Flutter cho mobile
- Supabase cho Backend và Database

(lúc refine idea của tôi thì bạn hãy recommend thêm)
