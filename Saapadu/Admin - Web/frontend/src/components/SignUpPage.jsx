import React, {useState} from 'react';
import {Link, useNavigate} from "react-router-dom";
import axios from 'axios';
import {Button, Col, Container, Form, Row} from 'react-bootstrap';
import {ToastContainer, toast} from "react-toastify";

export const SignUpPage = () => {
    const [form, setForm] = useState({
        college_name: '',
        email_id: '',
        domain_address: '',
        address: '',
        contact_no: ''
    });

    const navigate = useNavigate();

    const API_BASE = process.env.REACT_APP_API_BASE;

    const handleChange = (e) => {
        setForm({...form, [e.target.name]: e.target.value});
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await axios.post(
                `${API_BASE}/signUp`,
                form
            );
            if (res.status === 200) {
                toast.success(res.data.message || 'Organization created successfully!', {autoClose: 2000});
                const college = {id: res.data.college_id ?? res.data.collegeId, name: form.college_name}
                localStorage.setItem('college', JSON.stringify(college));
                setTimeout(() => navigate('/home'), 1500);
            }

        } catch (err) {
            const message = err.response?.data?.message || 'Error creating Organization';
            toast.error(message);
        }
    };

    return (
        <Container fluid className="min-vh-100 d-flex align-items-center justify-content-center">
            <Row className="w-100 justify-content-center">
                <Col xs={12} sm={10} md={8} lg={6} xl={5}>
                    <h1 className="text-center mb-4 text-dark fs-6">Sign Up for Your Organization</h1>
                    <Form className="p-4 shadow rounded bg-white" onSubmit={handleSubmit}>
                        <Form.Group className="mb-3">
                            <Form.Label className='text-dark'>College Name</Form.Label>
                            <Form.Control name="college_name" type="text" value={form.college_name}
                                          onChange={handleChange} required/>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label className='text-dark'>College Email Address</Form.Label>
                            <Form.Control name="email_id" type="email" value={form.email_id} onChange={handleChange}
                                          required/>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label className='text-dark'>College Domain Address</Form.Label>
                            <Form.Control name="domain_address" type="text" value={form.domain_address}
                                          onChange={handleChange} required/>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label className='text-dark'>College Address</Form.Label>
                            <Form.Control name="address" as="textarea" value={form.address} onChange={handleChange}
                                          required/>
                        </Form.Group>
                        <Form.Group className="mb-3">
                            <Form.Label className='text-dark'>College Contact Number</Form.Label>
                            <Form.Control name="contact_no" type="text" value={form.contact_no} onChange={handleChange}
                                          required/>
                        </Form.Group>
                        <Button variant="primary" type="submit" className="w-100">
                            Submit
                        </Button>
                        <p className="mt-3 text-dark">
                            Already created Organization? <Link to="/signIn">Sign in</Link>
                        </p>
                    </Form>
                </Col>
            </Row>
            <ToastContainer position="top-right"/>
        </Container>
    );
};