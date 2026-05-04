# TNFD 진단 도구 — 배포 가이드

## 1. Supabase 프로젝트 생성

1. https://supabase.com → **Start your project** → GitHub 로그인
2. **New project** → 이름: `tnfd-diagnostic`, 비밀번호 설정, 리전: Northeast Asia(Seoul)
3. 생성 완료(2~3분) 후 좌측 **SQL Editor** → 새 쿼리 → `supabase_schema.sql` 내용 붙여넣고 **RUN**
4. 좌측 **Authentication > Providers** → **Email** 토글 ON / **Confirm email** 토글 OFF (이메일 검증 끄기)
5. 좌측 **Settings > API** 에서 두 값 복사:
   - `Project URL` (예: `https://xxxxx.supabase.co`)
   - `anon public` 키

## 2. HTML 파일에 Supabase 정보 입력

`tnfd_app.html` 파일 상단의 두 줄을 위에서 복사한 값으로 교체:

```js
const SUPABASE_URL = 'https://여기에_본인_프로젝트.supabase.co';
const SUPABASE_ANON_KEY = '여기에_anon_public_키';
```

## 3. GitHub 레포 + Vercel 배포

```bash
cd "C:\Users\박지승\tnfd-diagnostic"
git init
git add .
git commit -m "init"
gh repo create tnfd-diagnostic-tool --public --source=. --push
```

그 다음 https://vercel.com → **Import Git Repository** → 위 레포 선택 → **Deploy** (설정 변경 불필요).

배포되면 `tnfd-diagnostic-tool.vercel.app` 같은 URL이 발급됩니다. 이 URL을 컨설턴트/외부 클라이언트에게 공유하면 됩니다.

## 4. 사용

1. 사이트 접속 → **회원가입** → 아이디/비밀번호 만들기 (이메일 X)
2. 로그인 → **+ 새 진단** → PDF 업로드 + Anthropic API 키 입력
3. 진단 완료 후 결과 검토 → 엑셀 내보내기

## 보안 정책 요약

- API 키는 **DB에 절대 저장 안 함** — 메모리에서만 사용 후 폐기
- 진단 결과는 **본인만 조회 가능** (Supabase RLS)
- 비밀번호는 Supabase가 bcrypt로 해시 저장
- 데모 단계: 비밀번호 분실 복구 미구현 — 필요 시 Supabase 대시보드 > Authentication > Users 에서 수동 리셋

## 비용

- Supabase 무료 티어: 월 50,000 인증 / 500MB DB / 1GB 스토리지 — 데모/소규모 충분
- Vercel Hobby: 무료
- Claude API: 사용자 본인 부담 (각자 자신의 키)
