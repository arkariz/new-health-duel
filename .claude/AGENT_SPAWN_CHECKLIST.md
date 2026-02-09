# Agent Spawn Checklist

**FOR LEAD AGENT:** Use this checklist when spawning any agent.

---

## ✅ Before Spawning Agent

- [ ] Task briefing file exists: `.claude/agents/task-{N}-{role}-brief.md`
- [ ] AGENT_CONTEXT.md is up to date with current status
- [ ] Task definition exists in `.claude/tasks/task-list.md`
- [ ] All required architecture docs exist

---

## ✅ Agent Prompt Must Include

### 1. Required Reading Section (in order):
```
📖 REQUIRED READING (Read in this order):
1. ⭐ .claude/AGENT_CONTEXT.md (MASTER CONTEXT - Read FIRST)
2. 📋 .claude/agents/task-{N}-{role}-brief.md (Your briefing)
3. 📚 .claude/tasks/task-list.md (Find Task #{N})
4. [Additional required docs...]

⚠️ DO NOT START until you've read AGENT_CONTEXT.md and your briefing.
```

### 2. Mission Statement:
```
YOUR MISSION - Task #{N}: [Task Name]
- Clear description of what they need to do
- Why it matters
- Working directory
```

### 3. Success Criteria:
```
✅ Success criterion 1
✅ Success criterion 2
✅ Success criterion 3
```

### 4. Failure Handling:
```
If blocked: PAUSE and report to lead agent.
DO NOT [list what not to do]
```

### 5. Execution Reference:
```
Follow detailed instructions in: .claude/agents/task-{N}-{role}-brief.md
```

### 6. Reporting:
```
Use reporting template from your briefing file.
```

### 7. Remember Checklist:
```
✅ Read AGENT_CONTEXT.md FIRST
✅ Read your briefing
✅ Follow briefing exactly
✅ PAUSE if blocked
```

---

## ✅ After Spawning Agent

- [ ] Agent ID recorded (for resume if needed)
- [ ] Output file path noted
- [ ] Task status updated to "in_progress"

---

## ✅ After Agent Completes

- [ ] Read agent output
- [ ] Verify success criteria met
- [ ] Update task status to "completed" or handle failure
- [ ] Unblock dependent tasks (if any)

---

## 📋 Standard Prompt Template

See: `.claude/agents/task-{N}-prompt-template.txt` for examples.

---

## 🚨 Common Mistakes to Avoid

❌ Spawning agent without briefing file
❌ Not including AGENT_CONTEXT.md in required reading
❌ Vague mission statement
❌ No success criteria
❌ No failure handling instructions
❌ Forgetting to update task status

---

**Remember:** Every agent needs context. Always start with AGENT_CONTEXT.md.
